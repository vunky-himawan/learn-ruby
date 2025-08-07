# frozen_string_literal: true

module Api
  module V1
    class Auth::RegistrationsController < Devise::RegistrationsController
      respond_to :json

      def create
        build_resource(sign_up_params)

        resource.save
        if resource.persisted?
          sign_in(resource, store: false)
        end

        respond_with(resource)
      end

      def respond_with(current_user, _opts = {})
        begin
          if resource.persisted?
            user = UserSerializer.new(current_user).serializable_hash[:data][:attributes]

            created(user, "User created successfully.")
          else
            errors = format_errors(resource.errors)

            unprocessable_entity("User couldn't be created successfully.", errors)
          end
        rescue StandardError => e
          Rails.logger.error("Registration failed: #{e.message}")

          error("An error occurred while processing your request.")
        end
      end

      private

      def sign_up_params
        params.require(:user).permit(:name, :email, :password, :password_confirmation, :role_id)
      end

      def format_errors(errors)
        seen_attributes = Set.new
        formatted = []

        errors.each do |error|
          next if seen_attributes.include?(error.attribute)

          formatted << {
            attribute: error.attribute.to_s,
            detail: "#{Utils::StringUtils.remove_underscores(error.attribute.to_s)} #{error.message}"
          }

          seen_attributes << error.attribute
        end

        formatted
      end
    end
  end
end
