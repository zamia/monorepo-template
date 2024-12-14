class UploadsController < ApplicationController
  def presign
    files = params.require(:files)
    Rails.logger.info "Files param: #{files.inspect}"

    s3_client = Aws::S3::Client.new(
      endpoint: "https://b35466db66614ddc79c776819d1d8262.r2.cloudflarestorage.com",
      access_key_id: ENV["CLOUDFLARE_R2_API_KEY"],
      secret_access_key: ENV["CLOUDFLARE_R2_API_SECRET"],
      region: "auto"
    )

    presigner = Aws::S3::Presigner.new(client: s3_client)
    presigned_urls = []
    file_urls = []

    files.each do |file|
      key = "#{SecureRandom.uuid}_#{file['name']}"

      # Generate presigned URL for upload
      presigned_url = presigner.presigned_url(
        :put_object,
        bucket: "animos-agent",
        key: key,
        expires_in: 3600,
        content_type: file["type"]
      )

      # Generate the permanent URL for the file
      file_url = "https://upload.animos.io/#{key}"

      presigned_urls << presigned_url
      file_urls << file_url
    end

    render json: { presigned_urls: presigned_urls, file_urls: file_urls }
  rescue ActionController::ParameterMissing => e
    Rails.logger.error "Parameter missing: #{e.message}"
    render json: { error: "Missing required parameter: files" }, status: :bad_request
  rescue StandardError => e
    Rails.logger.error "Error in presign: #{e.message}"
    render json: { error: e.message }, status: :internal_server_error
  end
end
