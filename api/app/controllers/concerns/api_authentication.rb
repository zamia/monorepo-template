# app/controllers/concerns/api_authentication.rb
module ApiAuthentication
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_api_request!
  end

  private

  def authenticate_api_request!
    api_key = extract_api_key
    return unauthorized_error unless api_key

    @api_key = ApiKey.find_by(key: api_key, status: "active")
    return unauthorized_error unless @api_key

    @api_key.touch(:last_used_at)
    create_session_for(@api_key.user)
  end

  def extract_api_key
    pattern = /^Bearer /
    header = request.headers["Authorization"]
    header&.gsub(pattern, "")
  end

  # TODO: api session is not necessary to store in database
  def create_session_for(user)
    user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |session|
      Current.session = session
    end
  end

  def unauthorized_error
    render json: { error: "Unauthorized" }, status: :unauthorized
  end
end
