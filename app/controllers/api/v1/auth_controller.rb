# frozen_string_literal: true

module Api
  module V1
    class AuthController < Api::ApiController
      # Skip authentication for login endpoint
      skip_before_action :authenticate_user, only: [:login]

      # POST /api/v1/auth/login
      def login
        # Find customer by email and password
        @customer = Customer.find_by(email: params[:email])
        
        if @customer && valid_password?(@customer, params[:password])
          # Generate a new token if one doesn't exist
          @customer.regenerate_token! unless @customer.token.present?
          
          render json: {
            data: {
              id: @customer.id,
              type: 'customer',
              attributes: {
                email: @customer.email,
                name: @customer.name,
                token: @customer.token,
                is_admin: @customer.admin?
              }
            }
          }, status: :ok
        else
          render json: {
            errors: [{
              code: 'invalid_credentials',
              detail: 'Invalid email or password',
              status: '401'
            }]
          }, status: :unauthorized
        end
      end

      # POST /api/v1/auth/logout
      def logout
        # Clear the token
        current_customer.update(token: nil)
        
        head :no_content
      end

      # GET /api/v1/auth/me
      def me
        render json: {
          data: {
            id: current_customer.id,
            type: 'customer',
            attributes: {
              email: current_customer.email,
              name: current_customer.name,
              is_admin: current_customer.admin?
            }
          }
        }, status: :ok
      end

      private

      # Simple password validation - in a real app, use a proper password hashing mechanism
      def valid_password?(customer, password)
        customer.password == password
      end
    end
  end
end
