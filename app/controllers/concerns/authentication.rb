# frozen_string_literal: true

module Authentication
  extend ActiveSupport::Concern

  included do
    # Make these methods available to views as well if needed
    helper_method :current_customer if respond_to?(:helper_method)
  end

  # Find the current customer based on the token in the Authorization header
  def current_customer
    @current_customer ||= authenticate_with_token
  end

  # Authenticate the customer with the token from the Authorization header
  def authenticate_with_token
    token = extract_token_from_header
    return nil unless token.present?

    Customer.find_by(token: token)
  end

  # Extract the token from the Authorization header
  def extract_token_from_header
    auth_header = request.headers['Authorization']
    return nil unless auth_header.present?

    # Format: 'Bearer <token>' or just '<token>'
    if auth_header.start_with?('Bearer ')
      auth_header.gsub('Bearer ', '')
    else
      auth_header
    end
  end

  # Ensure the user is authenticated before proceeding
  def authenticate_user
    unless current_customer
      render json: {
        errors: [{
          code: 'unauthorized',
          detail: 'Authentication required',
          status: '401'
        }]
      }, status: :unauthorized
    end
  end

  # Override pundit_user to use current_customer for authorization
  def pundit_user
    current_customer
  end
end
