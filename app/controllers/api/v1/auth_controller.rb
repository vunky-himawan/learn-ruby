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

  def login
    user_params = params.permit(:email, :password, :client_id)

    user = User.find_by(email: user_params[:email])

    return bad_request("Invalid credentials", [ "Email or password is incorrect" ]) unless user

    return bad_request("Invalid credentials", [ "Email or password is incorrect" ]) unless user.authenticate(user_params[:password])

    client_app = Doorkeeper::Application.find_by(uid: user_params[:client_id])

    return bad_request("Invalid client ID", [ "Client ID is incorrect" ]) unless client_app

    credentials = Doorkeeper::AccessToken.create!(
      application_id: client_app.id,
      resource_owner_id: user.id,
      expires_in: 2.hours,
      scopes: "public",
      use_refresh_token: true
    )

    success({
      access_token: credentials.token,
      refresh_token: credentials.refresh_token,
      expires_in: credentials.expires_in
    }, "Login successful")
  rescue StandardError => e
    internal_server_error("An unexpected error occurred", [ e.message ])
  end
end
