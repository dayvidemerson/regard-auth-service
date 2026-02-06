# frozen_string_literal: true

class JwtService
  ALGORITHM = "HS256"
  DEFAULT_EXPIRATION_HOURS = 24

  class << self
    def encode(payload, expiration_hours = DEFAULT_EXPIRATION_HOURS)
      token_payload = {
        **payload,
        exp: expiration_hours.hours.from_now.to_i,
        iat: Time.current.to_i
      }

      JWT.encode(token_payload, secret_key, ALGORITHM)
    end

    def decode(token)
      decoded = JWT.decode(token, secret_key, true, algorithm: ALGORITHM)
      HashWithIndifferentAccess.new(decoded.first)
    rescue JWT::ExpiredSignature
      raise TokenExpiredError
    rescue JWT::DecodeError
      raise InvalidTokenError
    end

    private

    def secret_key
      Rails.application.credentials.secret_key_base || ENV.fetch("SECRET_KEY_BASE")
    end
  end

  class TokenExpiredError < StandardError
    def message
      I18n.t("services.jwt_service.errors.token_expired")
    end
  end

  class InvalidTokenError < StandardError
    def message
      I18n.t("services.jwt_service.errors.invalid_token")
    end
  end
end
