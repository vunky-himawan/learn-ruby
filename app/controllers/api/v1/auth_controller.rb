class Api::V1::AuthController < ApplicationController
  include Respondable

  def register
    user_params = params.permit(:email, :password, :name, :role_id)

    existing_user = User.find_by(email: user_params[:email])
    if existing_user
      return bad_request("User already exists with this email", [ "Email already taken" ])
    end

    user = User.new(user_params)

    if user.save
      created(user, "User created successfully")
    else
      unprocessable_entity("Validation failed", user.errors.full_messages)
    end
  rescue StandardError => e
    internal_server_error("An unexpected error occurred", [ e.message ])
  end
end
