# frozen_string_literal: true

require "rails_helper"

RSpec.describe JwtService do
  let(:payload) { { user_id: "123e4567-e89b-12d3-a456-426614174000" } }
  let(:secret_key) { Rails.application.credentials.secret_key_base }

  describe ".encode" do
    it "returns a valid JWT token string", :aggregate_failures do
      token = described_class.encode(payload)

      expect(token).to be_a(String)
      expect(token.split(".").size).to eq(3)
    end

    it "includes the payload data in the token" do
      token = described_class.encode(payload)
      decoded = JWT.decode(token, secret_key, true, algorithm: "HS256").first

      expect(decoded["user_id"]).to eq(payload[:user_id])
    end

    it "sets expiration time in the token" do
      freeze_time do
        token = described_class.encode(payload)
        decoded = JWT.decode(token, secret_key, true, algorithm: "HS256").first

        expect(decoded["exp"]).to eq(24.hours.from_now.to_i)
      end
    end

    it "sets issued at time in the token" do
      freeze_time do
        token = described_class.encode(payload)
        decoded = JWT.decode(token, secret_key, true, algorithm: "HS256").first

        expect(decoded["iat"]).to eq(Time.current.to_i)
      end
    end

    it "allows custom expiration hours" do
      freeze_time do
        token = described_class.encode(payload, 48)
        decoded = JWT.decode(token, secret_key, true, algorithm: "HS256").first

        expect(decoded["exp"]).to eq(48.hours.from_now.to_i)
      end
    end
  end

  describe ".decode" do
    let(:token_expired_message) { I18n.t("services.jwt_service.errors.token_expired") }
    let(:invalid_token_message) { I18n.t("services.jwt_service.errors.invalid_token") }

    it "returns a HashWithIndifferentAccess with the payload", :aggregate_failures do
      token = described_class.encode(payload)
      decoded = described_class.decode(token)

      expect(decoded).to be_a(HashWithIndifferentAccess)
      expect(decoded[:user_id]).to eq(payload[:user_id])
      expect(decoded["user_id"]).to eq(payload[:user_id])
    end

    it "raises TokenExpiredError for expired tokens" do
      token = described_class.encode(payload, 0)

      travel 1.hour do
        expect { described_class.decode(token) }.to raise_error(JwtService::TokenExpiredError, token_expired_message)
      end
    end

    it "raises InvalidTokenError for invalid tokens" do
      expect { described_class.decode("invalid.token.here") }.to raise_error(JwtService::InvalidTokenError, invalid_token_message)
    end

    it "raises InvalidTokenError for tokens signed with wrong key" do
      wrong_token = JWT.encode(payload, "wrong_secret", "HS256")

      expect { described_class.decode(wrong_token) }.to raise_error(JwtService::InvalidTokenError, invalid_token_message)
    end

    it "raises InvalidTokenError for nil token" do
      expect { described_class.decode(nil) }.to raise_error(JwtService::InvalidTokenError, invalid_token_message)
    end
  end
end
