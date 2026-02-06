# frozen_string_literal: true

RSpec.shared_context "with authenticated user" do
  let(:authenticated_user) { create(:user) }
  let(:auth_token) { JwtService.encode(user_id: authenticated_user.id) }
  let(:auth_headers) { { "Authorization" => "Bearer #{auth_token}" } }
end

RSpec.shared_examples "requires authentication" do
  context "without authentication" do
    it "returns unauthorized when no token is provided" do
      make_request

      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body["error"]).to eq("Missing authorization token")
    end

    it "returns unauthorized with invalid token" do
      make_request(headers: { "Authorization" => "Bearer invalid.token.here" })

      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body["error"]).to eq(I18n.t("services.jwt_service.errors.invalid_token"))
    end

    it "returns unauthorized with expired token" do
      user = create(:user)
      expired_token = JwtService.encode({ user_id: user.id }, 0)

      travel 1.hour do
        make_request(headers: { "Authorization" => "Bearer #{expired_token}" })

        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body["error"]).to eq(I18n.t("services.jwt_service.errors.token_expired"))
      end
    end

    it "returns unauthorized when user not found" do
      token = JwtService.encode(user_id: "00000000-0000-0000-0000-000000000000")
      make_request(headers: { "Authorization" => "Bearer #{token}" })

      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body["error"]).to eq("User not found")
    end
  end
end
