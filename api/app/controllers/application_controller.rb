class ApplicationController < ActionController::API
  include Authentication

  def current_user
    Current.user
  end
end
