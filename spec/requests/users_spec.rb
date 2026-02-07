# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Users", type: :request do
  describe "POST /register" do
    let(:valid_params) do
      {
        user: {
          name: "Test User",
          email: "test@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    context "with valid parameters" do
      let(:expected_response) do
        {
          "user" => {
            "id" => be_present,
            "name" => "Test User",
            "email" => "test@example.com",
            "created_at" => be_present,
            "updated_at" => be_present
          },
          "token" => be_present
        }
      end

      it "creates a new user" do
        expect { post "/register", params: valid_params, as: :json }.to change(User, :count).by(1)
      end

      it "returns created status" do
        post "/register", params: valid_params, as: :json

        expect(response).to have_http_status(:created)
      end

      it "returns user data with token", :aggregate_failures do
        post "/register", params: valid_params, as: :json

        expect(response.parsed_body).to match(expected_response)
      end

      it "normalizes email to lowercase" do
        post "/register", params: valid_params.deep_merge(user: { email: "TEST@EXAMPLE.COM" }), as: :json

        expect(response.parsed_body["user"]["email"]).to eq("test@example.com")
      end
    end

    context "with invalid parameters" do
      it "returns unprocessable_content with missing name", :aggregate_failures do
        post "/register", params: valid_params.deep_merge(user: { name: "" }), as: :json

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.parsed_body["errors"]).to include("Name can't be blank")
      end

      it "returns unprocessable_content with invalid email", :aggregate_failures do
        post "/register", params: valid_params.deep_merge(user: { email: "invalid" }), as: :json

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.parsed_body["errors"]).to include("Email is invalid")
      end

      it "returns unprocessable_content with short password", :aggregate_failures do
        post "/register", params: valid_params.deep_merge(user: { password: "123", password_confirmation: "123" }), as: :json

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.parsed_body["errors"]).to include("Password is too short (minimum is 6 characters)")
      end

      it "returns unprocessable_content with mismatched passwords", :aggregate_failures do
        post "/register", params: valid_params.deep_merge(user: { password_confirmation: "different" }), as: :json

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.parsed_body["errors"]).to include("Password confirmation doesn't match Password")
      end

      it "returns unprocessable_content with duplicate email", :aggregate_failures do
        create(:user, email: "test@example.com")
        post "/register", params: valid_params, as: :json

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.parsed_body["errors"]).to include("Email has already been taken")
      end
    end
  end
end
