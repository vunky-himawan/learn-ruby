module Respondable
  extend ActiveSupport::Concern

  included do
    rescue_from StandardError, with: :handle_standard_error
  end

  def success(data = nil, message = "Success", status = :ok)
    render json: {
      statusCode: Rack::Utils::SYMBOL_TO_STATUS_CODE[status],
      message: message,
      data: data
    }, status: status
  end

  def created(data = nil, message = "Created")
    render json: {
      statusCode: 201,
      message: message,
      data: data
    }, status: :created
  end

  def no_content(message = "No Content")
    render json: {
      statusCode: 204,
      message: message
    }, status: :no_content
  end

  def redirected(url, message = "Redirected")
    render json: {
      statusCode: 302,
      message: message,
      url: url
    }, status: :found
  end

  def not_found(message = "Not Found")
    render json: {
      statusCode: 404,
      message: message
    }, status: :not_found
  end

  def unauthorized(message = "Unauthorized")
    render json: {
      statusCode: 401,
      message: message
    }, status: :unauthorized
  end

  def forbidden(message = "Forbidden")
    render json: {
      statusCode: 403,
      message: message
    }, status: :forbidden
  end

  def bad_request(message = "Bad Request", errors = [])
    render json: {
      statusCode: 400,
      message: message,
      errors: errors
    }, status: :bad_request
  end

  def conflict(message = "Conflict", errors = [])
    render json: {
      statusCode: 409,
      message: message,
      errors: errors
    }, status: :conflict
  end

  def internal_server_error(message = "Internal Server Error")
    render json: {
      statusCode: 500,
      message: message
    }, status: :internal_server_error
  end

  def unprocessable_entity(message = "Unprocessable Entity", errors = [])
    render json: {
      statusCode: 422,
      message: message,
      errors: errors
    }, status: :unprocessable_entity
  end

  def error(message = "An error occurred", status_code = :internal_server_error, errors = [])
    render json: {
      statusCode: Rack::Utils::SYMBOL_TO_STATUS_CODE[status_code],
      message: message,
      errors: errors
    }, status: status_code
  end

  private

  def handle_standard_error(exception)
    Rails.logger.error("\n[#{exception.class}] #{exception.message}\n#{exception.backtrace.join("\n")}")

    case exception
    when ActiveRecord::RecordNotFound
      not_found(exception.message)
    when ActiveRecord::RecordInvalid
      bad_request("Invalid record", exception.record.errors.full_messages)
    when ActionController::ParameterMissing
      bad_request("Required parameter missing", [ exception.param ])
    when ActionController::RoutingError
      not_found("Route not found")
    when ActionController::UnknownFormat
      not_found("Unknown format requested")
    when ActionController::InvalidAuthenticityToken
      unauthorized("Invalid authenticity token")
    when ActionController::InvalidCrossOriginRequest
      forbidden("Invalid cross-origin request")
    when ActionController::MethodNotAllowed, ActionController::UnknownHttpMethod
      error("Method not allowed", :method_not_allowed)
    when ActionController::BadRequest, ActionController::InvalidRequest
      bad_request("Bad request")
    when ActionController::ParameterTypeError
      bad_request("Parameter type error", [ exception.message ])
    else
      internal_server_error("An unexpected error occurred")
    end
  end
end
