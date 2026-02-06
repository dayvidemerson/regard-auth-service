# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Profiles API", type: :request do
  path "/profile" do
    get "Profile" do
      tags "Authentication"
      produces "application/json"
      security [bearerAuth: []]

      response "200", "profile returned" do
        include_context "with authenticated user"
        let(:request_headers) { auth_headers }

        schema "$ref" => "#/components/schemas/ProfileResponse"

        run_test!
      end

      response "401", "unauthorized" do
        let(:request_headers) { { "Authorization" => "Bearer invalid.token.here" } }

        schema "$ref" => "#/components/schemas/ErrorResponse"

        run_test!
      end
    end
  end
end
