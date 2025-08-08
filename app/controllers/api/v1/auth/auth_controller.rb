module Api
  module V1
    module Auth
      class AuthController < ApplicationController
        include AuthTokenHelper, ActionController::Cookies

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

        def sign_in
          return unless validate_required_params(%w[email password])

          begin
            ActiveRecord::Base.transaction do
              user = ::User.find_by(email: params[:email])

              if user&.authenticate(params[:password])
                last_sign_in_at = user.current_sign_in_at
                last_sign_in_ip = user.current_sign_in_ip

                user.update_columns(
                  sign_in_count:       user.sign_in_count + 1,
                  last_sign_in_at:     last_sign_in_at || Time.current,
                  last_sign_in_ip:     last_sign_in_ip || request.remote_ip,
                  current_sign_in_at:  Time.current,
                  current_sign_in_ip:  request.remote_ip,
                  updated_at:          Time.current
                )

                Rails.logger.info "User signed in successfully: #{user.email}"

                user_data = UserSerializer.new(user).serializable_hash[:data][:attributes]

                raw_refresh_token = SecureRandom.hex(64)
                hashed_refresh_token = Digest::SHA256.hexdigest(raw_refresh_token)

                ::RefreshToken.create!(
                  user_id: user.id,
                  token: hashed_refresh_token,
                  expires_at: 30.days.from_now
                )

                cookies.encrypted[:refresh_token] = {
                  value: raw_refresh_token,
                  httponly: true,
                  secure: Rails.env.production?,
                  same_site: :strict,
                  expires: 30.days.from_now
                }

                access_token = generate_auth_token(user, 15.minutes.from_now)

                success(user_data.merge(token: access_token), "User signed in successfully")
              else
                Rails.logger.warn "User sign in failed for #{params[:email]}"
                unauthorized("Invalid email or password")
              end
            end

          rescue ActiveRecord::RecordInvalid => e
            Rails.logger.error "User sign in validation error: #{e.message}"
            unprocessable_entity("Validation failed")
          rescue StandardError => e
            Rails.logger.error "Unexpected error during user sign in: #{e.message}"
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
