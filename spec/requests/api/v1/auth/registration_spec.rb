require 'rails_helper'

RSpec.describe "Registrations API", type: :request do
  let!(:role) { create(:role) }
  let!(:user) { create(:user, role: role) }

  context "when the request is valid" do
    it "creates a new user and returns a 201 status code" do
      valid_attributes = attributes_for(:user).merge(role_id: role.id)

      post api_v1_user_registration_path, params: { user: valid_attributes }

      expect(response).to have_http_status(201)

      json = JSON.parse(response.body)

      expect(json["statusCode"]).to eq(201)
      expect(json["message"]).to eq("User created successfully.")
      expect(json["data"]).to include(
        "email" => valid_attributes[:email],
        "name" => valid_attributes[:name]
      )
    end
  end

  context "when the request is invalid" do
    it "returns a 422 status code if the email is already taken" do
      existing_user = create(:user, role: role)

      duplicated_attributes = attributes_for(:user, email: existing_user.email).merge(role_id: role.id)

      post api_v1_user_registration_path, params: { user: duplicated_attributes }

      expect(response).to have_http_status(422)

      json = JSON.parse(response.body)

      expect(json["statusCode"]).to eq(422)
      expect(json["message"]).to eq("User couldn't be created successfully.")
      expect(json["details"]).to include(
        { "attribute" => "email", "detail" => "email has already been taken" }
      )
    end

    it "returns a 422 status code if the password is too short" do
      invalid_attributes = attributes_for(:user, password: "123", password_confirmation: "123").merge(role_id: role.id)

      post api_v1_user_registration_path, params: { user: invalid_attributes }

      expect(response).to have_http_status(422)

      json = JSON.parse(response.body)

      expect(json["statusCode"]).to eq(422)
      expect(json["message"]).to eq("User couldn't be created successfully.")
      expect(json["details"]).to include(
        { "attribute" => "password", "detail" => "password is too short (minimum is 8 characters)" }
      )
    end

    it "returns a 422 status code if the password confirmation doesn't match" do
      invalid_attributes = attributes_for(:user, password: "password123", password_confirmation: "password124").merge(role_id: role.id)

      post api_v1_user_registration_path, params: { user: invalid_attributes }

      expect(response).to have_http_status(422)

      json = JSON.parse(response.body)

      expect(json["statusCode"]).to eq(422)
      expect(json["message"]).to eq("User couldn't be created successfully.")
      expect(json["details"]).to include(
        { "attribute" => "password_confirmation", "detail" => "password confirmation doesn't match Password" }
      )
    end

    it "returns a 422 status code if the role_id is invalid" do
      invalid_attributes = attributes_for(:user, role_id: nil)

      post api_v1_user_registration_path, params: { user: invalid_attributes }

      expect(response).to have_http_status(422)

      json = JSON.parse(response.body)

      expect(json["statusCode"]).to eq(422)
      expect(json["message"]).to eq("User couldn't be created successfully.")
      expect(json["details"]).to include(
        { "attribute" => "role", "detail" => "role must exist" }
      )
    end

    it "returns a 422 status code if the name is missing" do
      invalid_attributes = attributes_for(:user, name: nil).merge(role_id: role.id)

      post api_v1_user_registration_path, params: { user: invalid_attributes }

      expect(response).to have_http_status(422)

      json = JSON.parse(response.body)

      expect(json["statusCode"]).to eq(422)
      expect(json["message"]).to eq("User couldn't be created successfully.")
      expect(json["details"]).to include(
        { "attribute" => "name", "detail" => "name can't be blank" }
      )
    end
  end
end
