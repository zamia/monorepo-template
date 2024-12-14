class UsersController < ApplicationController
  allow_unauthenticated_access only: [ :create ]

  def create
    user = User.new(user_params)

    if user.save
      render json: { status: :ok, message: "User created successfully" }
    else
      render json: {
        status: :unprocessable_entity,
        message: "Signup failed",
        errors: user.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.permit(:email_address, :password, :password_confirmation)
  end
end
