class ApplicationController < ActionController::API
  include Respondable
  config.api_only = true
end
