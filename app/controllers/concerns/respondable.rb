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

  def bad_request(message = "Bad Request")
    render json: {
      statusCode: 400,
      message: message
    }, status: :bad_request
  end

  def conflict(message = "Conflict")
    render json: {
      statusCode: 409,
      message: message
    }, status: :conflict
  end

  def internal_server_error(message = "Internal Server Error")
    render json: {
      statusCode: 500,
      message: message
    }, status: :internal_server_error
  end

  def unprocessable_entity(message = nil, resource = nil)
    res = {
      statusCode: 422,
      message: message.presence || "Validation failed"
    }

    if resource && resource.respond_to?(:errors) && resource.errors.any?
      res[:errors] = format_validation_details(resource)
      res[:message] = resource.errors.full_messages.join(", ") if message.blank?
    end

    render json: res, status: :unprocessable_content
  end

  def error(message = "An error occurred", status_code = :internal_server_error, errors = nil)
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
    when Errors::UnauthorizedError
      Rails.logger.warn("Unauthorized: #{exception.message}")
      unauthorized(exception.message)
    when Errors::NotFoundError
      Rails.logger.warn("Not Found: #{exception.message}")
      not_found(exception.message)
    when Errors::BadRequestError
      Rails.logger.warn("Bad Request: #{exception.message}")
      bad_request(exception.message)
    when ActiveRecord::RecordNotFound
      Rails.logger.warn("Record Not Found: #{exception.message}")
      not_found(exception.message)
    when ActiveRecord::RecordInvalid
      Rails.logger.warn("Record Invalid: #{exception.message}")
      unprocessable_entity("Validation failed", exception.record.errors.full_messages)
    when ActionController::RoutingError
      Rails.logger.warn("Routing Error: #{exception.message}")
      not_found("Route not found")
    when ActionController::UnknownFormat
      Rails.logger.warn("Unknown Format: #{exception.message}")
      not_found("Unknown format requested")
    when ActionController::InvalidAuthenticityToken
      Rails.logger.warn("Invalid Authenticity Token: #{exception.message}")
      unauthorized("Invalid authenticity token")
    when ActionController::InvalidCrossOriginRequest
      Rails.logger.warn("Invalid Cross-Origin Request: #{exception.message}")
      forbidden("Invalid cross-origin request")
    when ActionController::MethodNotAllowed, ActionController::UnknownHttpMethod
      Rails.logger.warn("Method Not Allowed: #{exception.message}")
      error("Method not allowed", :method_not_allowed)
    else
      internal_server_error("An unexpected error occurred")
    end
  end

  def format_validation_details(resource)
    resource.errors.map do |error|
      {
        attribute: error.attribute.to_s,
        error: error.message
      }
    end
  end
end
