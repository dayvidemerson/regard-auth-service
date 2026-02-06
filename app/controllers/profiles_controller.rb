# frozen_string_literal: true

class ProfilesController < ApplicationController
  def show
    render json: {
      id: current_user.id,
      name: current_user.name,
      email: current_user.email
    }, status: :ok
  end
end
