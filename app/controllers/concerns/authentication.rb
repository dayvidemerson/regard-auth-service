# frozen_string_literal: true

module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
  end

  private

  def authenticate_user!
    token = extract_token_from_header
    return render_unauthorized("Missing authorization token") unless token

    payload = JwtService.decode(token)
    @current_user = User.find_by(id: payload[:user_id])

    render_unauthorized("User not found") unless @current_user
  rescue JwtService::TokenExpiredError => e
    render_unauthorized(e.message)
  rescue JwtService::InvalidTokenError => e
    render_unauthorized(e.message)
  end

  def current_user
    @current_user
  end

  def extract_token_from_header
    header = request.headers["Authorization"]
    return nil unless header

    header.split(" ").last
  end

  def render_unauthorized(message = "Unauthorized")
    render json: { error: message }, status: :unauthorized
  end
end
