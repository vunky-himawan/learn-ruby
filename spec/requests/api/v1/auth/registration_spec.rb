require 'rails_helper'

RSpec.describe "Registrations API", type: :request do
  let!(:role) { create(:role) }
  let!(:user) { create(:user, role: role) }

  context "when the request is valid" do
    it "creates a new user and returns a 201 status code" do
      valid_attributes = attributes_for(:user).merge(role_id: role.id)

      post api_v1_auth_sign_up_path, params: valid_attributes, as: :json

      puts "Response body: #{response.body}"

      expect(response).to have_http_status(201)

      json = JSON.parse(response.body)

      expect(json["statusCode"]).to eq(201)
      expect(json["message"]).to eq("User created successfully")
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

        post api_v1_auth_sign_up_path, params: duplicated_attributes, as: :json

        expect(response).to have_http_status(422)

        json = JSON.parse(response.body)

        expect(json["statusCode"]).to eq(422)
        expect(json["message"]).to eq("User creation failed")
        expect(json["errors"]).to include(
          { "attribute" => "email", "error" => "has already been taken" }
        )
      end

        it "returns a 422 status code if the password is too short" do
          invalid_attributes = attributes_for(:user, password: "123", password_confirmation: "123").merge(role_id: role.id)

          post api_v1_auth_sign_up_path, params: invalid_attributes, as: :json

          expect(response).to have_http_status(422)

          json = JSON.parse(response.body)

          expect(json["statusCode"]).to eq(422)
          expect(json["message"]).to eq("User creation failed")
          expect(json["errors"]).to include(
            { "attribute" => "password", "error" => "is too short (minimum is 8 characters)" }
          )
        end

      it "returns a 422 status code if the password confirmation doesn't match" do
        invalid_attributes = attributes_for(:user, password: "password123", password_confirmation: "password124").merge(role_id: role.id)

        post api_v1_auth_sign_up_path, params: invalid_attributes, as: :json

        expect(response).to have_http_status(422)

        json = JSON.parse(response.body)

        expect(json["statusCode"]).to eq(422)
        expect(json["message"]).to eq("User creation failed")
        expect(json["errors"]).to include(
          { "attribute" => "password_confirmation", "error" => "doesn't match Password" }
        )
      end

      it "returns a 422 status code if the role_id is invalid" do
        invalid_attributes = attributes_for(:user, role_id: -10)

        post api_v1_auth_sign_up_path, params: invalid_attributes, as: :json

        expect(response).to have_http_status(422)

        json = JSON.parse(response.body)

        expect(json["statusCode"]).to eq(422)
        expect(json["message"]).to eq("User creation failed")
        expect(json["errors"]).to include(
          { "attribute" => "role", "error" => "must exist" }
        )
      end

      it "returns a 400 status code if the name is missing" do
        invalid_attributes = attributes_for(:user, name: nil).merge(role_id: role.id)

        post api_v1_auth_sign_up_path, params: invalid_attributes, as: :json

        expect(response).to have_http_status(400)

        json = JSON.parse(response.body)

        expect(json["statusCode"]).to eq(400)
        expect(json["message"]).to eq("Missing required parameters: name")
      end
  end
end
