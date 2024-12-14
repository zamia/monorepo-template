class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[create ]
  rate_limit to: 10, within: 3.minutes, only: :create

  def create
    auth_params = params.permit(:password, :email)
    auth_params[:email_address] = auth_params.delete(:email)

    if user = User.authenticate_by(auth_params)
      start_new_session_for user
      render json: { status: :ok, token: Current.session.token, message: "Logged in successfully." }
    else
      render json: { status: :unauthorized, message: "Try another email address or password." }, status: :unauthorized
    end
  end

  def destroy
    Rails.logger.info "Logging out user #{Current.user.id} #{request.headers["Authorization"]}"
    terminate_session
    render json: { status: :ok, message: "Logged out successfully." }
  end
end
