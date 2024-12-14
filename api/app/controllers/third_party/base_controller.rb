module ThirdParty
  class BaseController < ApplicationController
    allow_unauthenticated_access
  end
end
