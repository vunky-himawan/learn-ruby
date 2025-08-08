require "swagger_helper"

RSpec.describe "Auth API", type: :request, swagger_doc: "v1/swagger.yaml" do
  path "/api/v1/auth/sign_up" do
    post("Register a new user") do
      tags "Auth"
      consumes "application/json"
      produces "application/json"

      parameter name: :user, in: :body, schema: {
        type: :object,
        required: [ :name, :email, :password, :password_confirmation, :role_id ],
        properties: {
            name: { type: :string, example: "John Doe" },
            email: { type: :string, format: "email", example: "john.doe@example.com" },
            password: { type: :string, example: "password123" },
            password_confirmation: { type: :string, example: "password123" },
            role_id: { type: :integer, example: 1 }
        }
      }

      response(201, "User created successfully") do
        let!(:role) { create(:role) }

        let(:user) do
          {
              name: "John Doe",
              email: "john.doe@example.com",
              password: "password123",
              password_confirmation: "password123",
              role_id: role.id
          }
        end

        run_test!
      end

      response(400, "User couldn't be created successfully") do
        let(:user) do
          {
              name: "422 John Doe",
              email: "john.doe@example.com",
              password: "password123",
              password_confirmation: "password123"
          }
        end

        run_test!
      end

      response(422, "User couldn't be created successfully") do
        let(:user) do
          {
              name: "422 John Doe",
              email: "john.doe@example.com",
              password: "password123",
              password_confirmation: "password123",
              role_id: -10
          }
        end

        run_test!
      end
    end
  end

  path "/api/v1/auth/sign_in" do
    post ("Sign in a user") do
      tags "Auth"
      consumes "application/json"
      produces "application/json"

      parameter name: :auth, in: :body, schema: {
        type: :object,
        required: [ :email, :password ],
        properties: {
          email: { type: :string, format: "email", example: "john.doe@example.com" },
          password: { type: :string, example: "password123" }
        }
      }

      response(200, "User signed in successfully") do
        let!(:role) { create(:role) }
        let!(:user) { create(:user, role: role, email: "john.doe@example.com", password: "password123") }
        let(:password) { "password123" }

        let(:auth) do
          {
            email: user.email,
            password: password
          }
        end

        run_test!
      end

      response(401, "Invalid email or password") do
        let!(:role) { create(:role) }
        let!(:user) { create(:user, role: role, email: "john.doe@example.com", password: "password123") }

        let(:auth) do
          {
            email: user.email,
            password: "wrongpassword"
          }
        end

        run_test!
      end

      response(400, "Missing email or password") do
        let!(:role) { create(:role) }
        let!(:user) { create(:user, role: role, email: "john.doe@example.com", password: "password123") }

        let(:auth) do
          {
            email: user.email
          }
        end

        run_test!
      end
    end
  end
end
