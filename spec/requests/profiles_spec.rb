# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Profiles", type: :request do
  describe "GET /profile" do
    include_context "with authenticated user"

    it_behaves_like "requires authentication" do
      def make_request(headers: {})
        get "/profile", headers: headers, as: :json
      end
    end

    context "with valid authentication" do
      it "returns ok status" do
        get "/profile", headers: auth_headers, as: :json

        expect(response).to have_http_status(:ok)
      end

      it "returns current user profile data" do
        get "/profile", headers: auth_headers, as: :json

        body = response.parsed_body

        expect(body["id"]).to eq(authenticated_user.id)
        expect(body["name"]).to eq(authenticated_user.name)
        expect(body["email"]).to eq(authenticated_user.email)
      end

      it "does not expose sensitive data" do
        get "/profile", headers: auth_headers, as: :json

        body = response.parsed_body

        expect(body).not_to have_key("password_digest")
        expect(body).not_to have_key("password")
      end
    end
  end
end
