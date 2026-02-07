# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Sessions", type: :request do
  describe "POST /login" do
    let!(:user) { create(:user, email: "user@example.com", password: "password123") }

    context "with valid credentials" do
      let(:valid_params) { { email: "user@example.com", password: "password123" } }

      it "returns ok status" do
        post "/login", params: valid_params, as: :json

        expect(response).to have_http_status(:ok)
      end

      it "returns success message and token", :aggregate_failures do
        post "/login", params: valid_params, as: :json

        body = response.parsed_body

        expect(body["token"]).to be_present
        expect(body["expires_in"]).to eq(24.hours.to_i)
      end

      it "returns a valid JWT token" do
        post "/login", params: valid_params, as: :json

        token = response.parsed_body["token"]
        decoded = JwtService.decode(token)

        expect(decoded[:user_id]).to eq(user.id)
      end

      it "is case-insensitive for email" do
        post "/login", params: { email: "USER@EXAMPLE.COM", password: "password123" }, as: :json

        expect(response).to have_http_status(:ok)
      end
    end

    context "with invalid credentials" do
      it "returns unauthorized with wrong password", :aggregate_failures do
        post "/login", params: { email: "user@example.com", password: "wrongpassword" }, as: :json

        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body["error"]).to eq("Invalid email or password")
      end

      it "returns unauthorized with non-existent email", :aggregate_failures do
        post "/login", params: { email: "nonexistent@example.com", password: "password123" }, as: :json

        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body["error"]).to eq("Invalid email or password")
      end

      it "returns unauthorized with missing email", :aggregate_failures do
        post "/login", params: { password: "password123" }, as: :json

        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body["error"]).to eq("Invalid email or password")
      end

      it "returns unauthorized with missing password", :aggregate_failures do
        post "/login", params: { email: "user@example.com" }, as: :json

        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body["error"]).to eq("Invalid email or password")
      end
    end
  end
end
