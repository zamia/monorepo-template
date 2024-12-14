class TriggerExecutionJob < ApplicationJob
    queue_as :default

    # Make process_trigger public
    def process_trigger(trigger)
      Rails.logger.info "Starting process_trigger for trigger #{trigger.id}"
      start_time = Time.current

      begin
        # Get customers for the current user
        customers = Customer.where(user_id: trigger.user_id)
        Rails.logger.info "Found #{customers.count} customers for user #{trigger.user_id}"
        
        matching_customers = []
        
        customers.each do |customer|
          customer_data = {
            'name' => customer.name,
            'phone' => customer.phone
          }.merge(customer.metadata || {})

          Rails.logger.info "Evaluating customer #{customer.id} with data: #{customer_data}"
          Rails.logger.info "Target field: #{trigger.target_field}, Comparison type: #{trigger.comparison_type}, Value: #{trigger.comparison_value}"

          if evaluate_condition(trigger, customer_data)
            Rails.logger.info "Customer #{customer.id} matches conditions"
            matching_customers << customer
          else
            Rails.logger.info "Customer #{customer.id} does not match conditions"
          end
        end

        task = nil
        if matching_customers.any?
          task = create_task(trigger, matching_customers)
          tasks_created = 1
        else
          tasks_created = 0
        end

        # Record successful execution
        TriggerExecution.record_execution(
          trigger: trigger,
          status: 'success',
          customers_matched: matching_customers.size,
          task_ids: task ? [task.id] : [],
          metadata: {
            matched_customer_ids: matching_customers.pluck(:id)
          }
        )

        task
      rescue StandardError => e
        # Record failed execution
        TriggerExecution.record_execution(
          trigger: trigger,
          status: 'failed',
          metadata: {
            start_time: start_time,
            error: {
              message: e.message,
              backtrace: e.backtrace&.first(5),
              type: e.class.name
            }
          }
        )
        
        Rails.logger.error "Error in process_trigger: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        raise e
      end
    end

    def perform(*args)
      # Find all active triggers
      Trigger.active.find_each(batch_size: 20) do |trigger|
        begin
          process_trigger(trigger)
        rescue StandardError => e
          Rails.logger.error("Error executing trigger #{trigger.id}: #{e.message}")
          next
        end
      end
    end

    private

    def should_execute_now?(trigger)
      current_time = Time.current

      # Check if it's around 10 AM (within 5-minute window)
      return false unless current_time.hour == 10 && current_time.min <= 5

      # Check if trigger should run today based on schedule_type
      case trigger.schedule_type
      when "daily"
        true
      when "weekly"
        # Assuming schedule_days is stored in metadata as an array of day names
        trigger.metadata["schedule_days"]&.include?(current_time.strftime("%A").downcase)
      when "monthly"
        # Assuming schedule_days is stored in metadata as an array of day numbers (1-31)
        trigger.metadata["schedule_days"]&.include?(current_time.day.to_s)
      else
        false
      end
    end

    def evaluate_condition(trigger, customer_data)
      # Convert wildcard pattern to regex
      if trigger.target_field.include?('*')
        # Convert * to .* for regex and escape other special characters
        pattern = Regexp.new(trigger.target_field.gsub(/[^A-Za-z0-9_*]/) { |s| "\\#{s}" }
                                           .gsub('*', '.*'))
        matching_fields = customer_data.keys.select { |key| key.match?(pattern) }
        Rails.logger.info "Regex pattern '#{pattern}' matched fields: #{matching_fields}"
        field_values = matching_fields.map { |field| customer_data[field] }.compact
      else
        # Single field case
        field_values = [customer_data[trigger.target_field]].compact
      end

      return false if field_values.empty?

      # Try each matching field value
      field_values.any? do |field_value|
        begin
          # Parse date with American format (MM/DD/YYYY)
          field_date = if field_value.is_a?(String)
            if field_value.match?(%r{\d{1,2}/\d{1,2}/\d{4}})
              Date.strptime(field_value, "%m/%d/%Y")
            else
              Date.parse(field_value)
            end
          else
            field_value
          end

          if field_date.is_a?(Date) || field_date.is_a?(Time)
            # Handle date comparison
            comparison_date = if trigger.comparison_value.downcase == "today"
              Date.current
            else
              if trigger.comparison_value.match?(%r{\d{1,2}/\d{1,2}/\d{4}})
                Date.strptime(trigger.comparison_value, "%m/%d/%Y")
              else
                Date.parse(trigger.comparison_value)
              end
            end

            # Apply date calculation if present
            if trigger.date_calculation.present?
              case trigger.date_calculation
              when "plus_days"
                comparison_date = comparison_date + trigger.date_value.to_i
              when "minus_days"
                comparison_date = comparison_date - trigger.date_value.to_i
              end
            end

            Rails.logger.info("Field date: #{field_date}")
            Rails.logger.info("Comparison date: #{comparison_date}")
            
            # Compare dates (only month and day)
            case trigger.comparison_type
            when "equals"
              [ field_date.month, field_date.day ] == [ comparison_date.month, comparison_date.day ]
            when "contains"
              field_date.strftime("%m-%d").include?(comparison_date.strftime("%m-%d"))
            when "greater_than"
              field_date.strftime("%m-%d") > comparison_date.strftime("%m-%d")
            when "less_than"
              field_date.strftime("%m-%d") < comparison_date.strftime("%m-%d")
            else
              false
            end
          else
            # Fall back to regular string comparison
            case trigger.comparison_type
            when "equals"
              field_value.to_s.downcase == trigger.comparison_value.to_s.downcase
            when "contains"
              field_value.to_s.downcase.include?(trigger.comparison_value.to_s.downcase)
            else
              false
            end
          end
        rescue Date::Error
          # If date parsing fails, fall back to regular string comparison
          case trigger.comparison_type
          when "equals"
            field_value.to_s.downcase == trigger.comparison_value.to_s.downcase
          when "contains"
            field_value.to_s.downcase.include?(trigger.comparison_value.to_s.downcase)
          else
            false
          end
        end
      end
    end

    def create_task(trigger, customers)
      task = Task.new(
        user: trigger.user,
        agent: trigger.agent,
        trigger_id: trigger.id,
        name: "#{trigger.name} - #{Time.current}",
        json_content: {
          customers: customers.map { |customer|
            {
              name: customer.name,
              number: customer.phone,
              id: customer.id,
              profile: customer.metadata || {}
            }
          }
        }
      )

      unless task.save
        Rails.logger.error("Failed to create task: #{task.errors.full_messages.join(', ')}")
        Rails.logger.error("Task attributes: #{task.attributes}")
        Rails.logger.error("Trigger: #{trigger.id}, Customers count: #{customers.count}")
        Rails.logger.error("Message: #{message}")
      end

      task
    end
end
