# frozen_string_literal: true

class UsersController < ApplicationController
  skip_before_action :authenticate_user!, only: :create

  def create
    user = User.new(user_params)

    if user.save
      token = JwtService.encode(user_id: user.id)
      render json: {
        user: user_response(user),
        token: token
      }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_content
    end
  end

  private

  def user_params
    params.expect(user: %i[name email password password_confirmation])
  end

  def user_response(user)
    user.slice(:id, :name, :email, :created_at, :updated_at)
  end
end
