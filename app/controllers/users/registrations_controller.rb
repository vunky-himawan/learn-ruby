# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :json

  def respond_with(current_user, _opts = {})
    puts "Payload: #{request.body.read}"
    puts "Resource: #{resource.inspect}"

    if resource.persisted?
      user = UserSerializer.new(current_user).serializable_hash[:data][:attributes]

      success({
        "hallo": user
      }, "Login successfully.")
    else
      errors = format_errors(resource.errors)

      unprocessable_entity("User couldn't be created successfully.", errors)
    end
  end

  private

  def format_errors(errors)
    seen_attributes = Set.new
    formatted = []

    errors.each do |error|
      next if seen_attributes.include?(error.attribute)

      formatted << {
        attribute: error.attribute.to_s,
        detail: "#{error.attribute} #{error.message}"
      }

      seen_attributes << error.attribute
    end

    formatted
  end
end
