# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Users API", type: :request do
  path "/register" do
    post "Register user" do
      tags "Authentication"
      consumes "application/json"
      produces "application/json"
      parameter name: :payload, in: :body, schema: { "$ref" => "#/components/schemas/RegisterRequest" }

      response "201", "user created" do
        let(:payload) do
          {
            user: {
              name: "Test User",
              email: "test@example.com",
              password: "password123",
              password_confirmation: "password123"
            }
          }
        end

        schema "$ref" => "#/components/schemas/RegisterResponse"

        run_test!
      end

      response "422", "validation errors" do
        let(:payload) { { user: { name: "", email: "invalid", password: "123" } } }

        schema "$ref" => "#/components/schemas/ValidationErrorResponse"

        run_test!
      end
    end
  end
end
