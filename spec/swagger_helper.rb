# frozen_string_literal: true

require "rails_helper"

RSpec.configure do |config|
  config.swagger_root = Rails.root.join("swagger").to_s

  config.swagger_docs = {
    "v1/swagger.yaml" => {
      openapi: "3.0.1",
      info: {
        title: "Regard Auth Service API",
        version: "v1"
      },
      paths: {},
      components: {
        securitySchemes: {
          bearerAuth: {
            type: :http,
            scheme: :bearer,
            bearerFormat: :JWT
          }
        },
        schemas: {
          ErrorResponse: {
            type: :object,
            properties: {
              error: { type: :string }
            },
            required: ["error"]
          },
          ValidationErrorResponse: {
            type: :object,
            properties: {
              errors: {
                type: :array,
                items: { type: :string }
              }
            },
            required: ["errors"]
          },
          RegisterRequest: {
            type: :object,
            properties: {
              user: {
                type: :object,
                properties: {
                  name: { type: :string, example: "Test User" },
                  email: { type: :string, example: "test@example.com" },
                  password: { type: :string, example: "password123" },
                  password_confirmation: { type: :string, example: "password123" }
                },
                required: %w[name email password password_confirmation]
              }
            },
            required: ["user"]
          },
          UserResponse: {
            type: :object,
            properties: {
              id: { type: :string, format: :uuid },
              name: { type: :string },
              email: { type: :string },
              created_at: { type: :string, format: "date-time" },
              updated_at: { type: :string, format: "date-time" }
            },
            required: %w[id name email created_at updated_at]
          },
          RegisterResponse: {
            type: :object,
            properties: {
              user: { "$ref" => "#/components/schemas/UserResponse" },
              token: { type: :string }
            },
            required: %w[user token]
          },
          LoginRequest: {
            type: :object,
            properties: {
              email: { type: :string, example: "test@example.com" },
              password: { type: :string, example: "password123" }
            },
            required: %w[email password]
          },
          LoginResponse: {
            type: :object,
            properties: {
              token: { type: :string },
              expires_in: { type: :integer, example: 86_400 }
            },
            required: %w[message token expires_in]
          },
          ProfileResponse: {
            type: :object,
            properties: {
              id: { type: :string, format: :uuid },
              name: { type: :string },
              email: { type: :string }
            },
            required: %w[id name email]
          }
        }
      }
    }
  }

  config.swagger_format = :yaml
end
