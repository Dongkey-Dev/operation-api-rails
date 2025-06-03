# frozen_string_literal: true

module TokenScopable
  extend ActiveSupport::Concern

  included do
    # Add a scope to filter records by the customer associated with a token
    # This is meant to be used in controllers where current_customer is available
    scope :by_token_customer, lambda { |customer|
      return all unless customer.present?
      
      if self == CommandResponse
        # For CommandResponse, filter by the associated command's customer_id
        joins(:command).where(commands: { customer_id: customer.id })
      elsif respond_to?(:column_names) && column_names.include?('customer_id')
        # For models with customer_id column
        where(customer_id: customer.id)
      else
        # Default case - no filtering
        all
      end
    }
  end
end
