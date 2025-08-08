class ApplicationController < ActionController::API
  include Respondable, ContentTypeValidator, ParamValidator
  config.api_only = true
end
