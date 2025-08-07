class ApplicationController < ActionController::API
  include Respondable
  config.api_only = true

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name, :role_id ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name ])
  end
end
