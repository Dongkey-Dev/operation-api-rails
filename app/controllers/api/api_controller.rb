# frozen_string_literal: true

class Api::ApiController < ApplicationController
  include Authentication
  include Pundit::Authorization
  include TokenCustomerFiltering

  # Rescue from Pundit authorization errors
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  # Handle JSON parse errors
  rescue_from ActionDispatch::Http::Parameters::ParseError do |exception|
    render json: {
      errors: [ {
        code: "invalid_json",
        detail: "The request body contains invalid JSON",
        status: "400"
      } ]
    }, status: :bad_request
  end

  private

  def user_not_authorized
    render json: {
      errors: [ {
        code: "forbidden",
        detail: "You are not authorized to perform this action",
        status: "403"
      } ]
    }, status: :forbidden
  end

  def record_not_found
    render json: {
      errors: [ {
        code: "not_found",
        detail: "The requested resource could not be found",
        status: "404"
      } ]
    }, status: :not_found
  end

  # Format validation errors in a consistent way
  def format_validation_errors(record)
    record.errors.map do |error|
      {
        code: "validation_error",
        detail: error.full_message,
        source: { pointer: "/data/attributes/#{error.attribute}" },
        status: "422"
      }
    end
  end
end
