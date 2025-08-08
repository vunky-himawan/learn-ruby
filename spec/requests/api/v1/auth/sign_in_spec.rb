require 'rails_helper'

RSpec.describe "Sign In API", type: :request do
  let!(:role) { create(:role) }
  let!(:user) { create(:user, role: role, email: "john.doe@example.com", password: "password123") }

  context "when the request is valid" do
    it "signs in the user and returns a 200 status code" do
      valid_attributes = {
        email: user.email,
        password: "password123"
      }

      post api_v1_auth_sign_in_path, params: valid_attributes, as: :json

      expect(response).to have_http_status(200)

      json = JSON.parse(response.body)

      expect(json["statusCode"]).to eq(200)
      expect(json["message"]).to eq("User signed in successfully")
      expect(json["data"]).to include(
        "email" => user.email,
        "name" => user.name
      )
      expect(json["data"]).to have_key("token")
    end
  end

  context "when the request is invalid" do
    it "returns a 401 status code if the email doesn't exist" do
      invalid_attributes = {
        email: "nonexistent@example.com",
        password: "password123"
      }

      post api_v1_auth_sign_in_path, params: invalid_attributes, as: :json

      expect(response).to have_http_status(401)

      json = JSON.parse(response.body)

      expect(json["statusCode"]).to eq(401)
      expect(json["message"]).to eq("Invalid email or password")
    end

    it "returns a 401 status code if the password is incorrect" do
      invalid_attributes = {
        email: user.email,
        password: "wrongpassword"
      }

      post api_v1_auth_sign_in_path, params: invalid_attributes, as: :json

      expect(response).to have_http_status(401)

      json = JSON.parse(response.body)

      expect(json["statusCode"]).to eq(401)
      expect(json["message"]).to eq("Invalid email or password")
    end

    it "returns a 400 status code if the email is missing" do
      invalid_attributes = {
        password: "password123"
      }

      post api_v1_auth_sign_in_path, params: invalid_attributes, as: :json

      expect(response).to have_http_status(400)

      json = JSON.parse(response.body)

      expect(json["statusCode"]).to eq(400)
      expect(json["message"]).to eq("Missing required parameters: email")
    end

    it "returns a 400 status code if the password is missing" do
      invalid_attributes = {
        email: user.email
      }

      post api_v1_auth_sign_in_path, params: invalid_attributes, as: :json

      expect(response).to have_http_status(400)

      json = JSON.parse(response.body)

      expect(json["statusCode"]).to eq(400)
      expect(json["message"]).to eq("Missing required parameters: password")
    end

    it "returns a 400 status code if both email and password are missing" do
      invalid_attributes = {}

      post api_v1_auth_sign_in_path, params: invalid_attributes, as: :json

      expect(response).to have_http_status(400)

      json = JSON.parse(response.body)

      expect(json["statusCode"]).to eq(400)
      expect(json["message"]).to eq("Missing required parameters: email, password")
    end

    it "returns a 400 status code if email is empty" do
      invalid_attributes = {
        email: "",
        password: "password123"
      }

      post api_v1_auth_sign_in_path, params: invalid_attributes, as: :json

      expect(response).to have_http_status(400)

      json = JSON.parse(response.body)

      expect(json["statusCode"]).to eq(400)
      expect(json["message"]).to eq("Missing required parameters: email")
    end

    it "returns a 400 status code if password is empty" do
      invalid_attributes = {
        email: user.email,
        password: ""
      }

      post api_v1_auth_sign_in_path, params: invalid_attributes, as: :json

      expect(response).to have_http_status(400)

      json = JSON.parse(response.body)

      expect(json["statusCode"]).to eq(400)
      expect(json["message"]).to eq("Missing required parameters: password")
    end
  end
end
