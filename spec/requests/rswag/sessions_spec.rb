# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Sessions API", type: :request do
  path "/login" do
    post "Login" do
      tags "Authentication"
      consumes "application/json"
      produces "application/json"
      parameter name: :payload, in: :body, schema: { "$ref" => "#/components/schemas/LoginRequest" }

      response "200", "login success" do
        let!(:user) { create(:user, email: "user@example.com", password: "password123") }
        let(:payload) { { email: "user@example.com", password: "password123" } }

        schema "$ref" => "#/components/schemas/LoginResponse"

        run_test!
      end

      response "401", "invalid credentials" do
        let(:payload) { { email: "user@example.com", password: "wrongpassword" } }

        schema "$ref" => "#/components/schemas/ErrorResponse"

        run_test!
      end
    end
  end
end
