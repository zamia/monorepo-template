module Integration
  class BaseController < ::ApplicationController
    include ApiAuthentication
    allow_unauthenticated_access
  end
end