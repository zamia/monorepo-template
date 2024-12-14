require "csv"
require "open-uri"

class TaskParseJob < ApplicationJob
  queue_as :default

  def perform(task_id)
    task = Task.find(task_id)

    if task.content.present?
      create_task_jobs_by_content(task)
    end

    if task.file_urls.present?
      create_task_jobs_by_file(task)
    end

    if task.json_content.present?
      create_task_jobs_by_json(task)
    end
  end

  private

  def create_task_jobs_by_json(task)
    customers = task.json_content["customers"]
    return if customers.blank?

    customers.each do |customer|
      create_task_job(task, customer["name"], customer["number"], customer["profile"])
    end
  end

  def create_task_jobs_by_content(task)
    lines = task.content.split("\n").map(&:strip).reject(&:empty?)
    return if lines.empty?

    begin
      # Parse headers from the first line
      headers = CSV.parse_line(lines.first)
      return unless headers && headers.size >= 2

      # Process remaining lines
      lines[1..].each do |line|
        row = CSV.parse_line(line)
        next unless row && row.size >= 2

        name = row[0]&.strip
        number = row[1]&.strip

        # Create profile hash from remaining columns using headers
        profile = {}
        headers[2..].each_with_index do |header, index|
          next if header.nil?
          profile[header.strip.downcase] = row[2 + index]&.strip
        end

        create_task_job(task, name, number, profile)
      end
    rescue CSV::MalformedCSVError => e
      Rails.logger.error("Error parsing content in task #{task.id}: #{e.message}")
    end
  end

  def create_task_jobs_by_file(task)
    task.file_urls.each do |url|
      begin
        # Download and parse the CSV file
        csv_content = URI.open(url).read
        CSV.parse(csv_content, headers: true).each_with_index do |row, index|
          next if row.all?(&:nil?) || row.all?(&:empty?) # Skip empty rows
          next unless row.size >= 2

          name = row[0]&.strip
          number = row[1]&.strip

          # Create profile hash from remaining columns using headers
          profile = {}
          row.headers[2..].each_with_index do |header, index|
            next if header.nil?
            profile[header.strip.downcase] = row[2 + index]&.strip
          end

          create_task_job(task, name, number, profile)
        end
      rescue OpenURI::HTTPError => e
        Rails.logger.error("Error downloading file from #{url} for task #{task.id}: #{e.message}")
        next
      rescue CSV::MalformedCSVError => e
        Rails.logger.error("Error parsing CSV from #{url} for task #{task.id}: #{e.message}")
        next
      rescue StandardError => e
        Rails.logger.error("Unexpected error processing file #{url} for task #{task.id}: #{e.message}")
        next
      end
    end
  end

  def create_task_job(task, name, number, profile)
    return if name.blank? || number.blank?

    TaskJob.create!(
      task: task,
      status: "pending",
      customer_name: name,
      customer_number: Util.full_phone_number(number), # normalize phone number,
      customer_profile: profile || {}
    )

    # update task's metrics column
    task.metrics = { "total_jobs" => 0, "finished_jobs" => 0 } if task.metrics.blank?
    task.metrics["total_jobs"] += 1
    task.save!
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error("Error creating TaskJob for task #{task.id}: #{e.message}")
  end
end
