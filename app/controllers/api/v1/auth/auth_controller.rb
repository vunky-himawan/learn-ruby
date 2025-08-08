module Api
  module V1
    module Auth
      class AuthController < ApplicationController
        wrap_parameters false

        before_action :validate_content_type, only: [ :sign_up ]

        def sign_up
          return unless validate_required_params(%w[name email password password_confirmation role_id])

          begin
            ActiveRecord::Base.transaction do
              user = ::User.new(user_params)

              if user.save
                Rails.logger.info "User registered successfully: #{user.email}"

                user_data = UserSerializer.new(user).serializable_hash[:data][:attributes]

                created(user_data, "User created successfully")
              else
                Rails.logger.warn "User creation failed for #{user.email}: #{user.errors.full_messages}"

                unprocessable_entity("User creation failed", user)
              end
            end

          rescue ActiveRecord::RecordInvalid => e
            Rails.logger.error "User creation validation error: #{e.message}"
            unprocessable_entity("Validation failed")
          rescue StandardError => e
            Rails.logger.error "Unexpected error during user creation: #{e.message}"
            internal_server_error("Something went wrong")
          end
        end

        private

        def user_params
          params.permit(:name, :email, :password, :password_confirmation, :role_id)
        end
      end
    end
  end
end
