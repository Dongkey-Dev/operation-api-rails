# frozen_string_literal: true

# This concern provides token-based customer filtering functionality for controllers
# It automatically applies the by_token_customer scope to all queries unless customer_id is explicitly provided
module TokenCustomerFiltering
  extend ActiveSupport::Concern

  included do
    # Apply token-based customer filtering to specified resource classes
    class_attribute :token_filtered_resources, default: []
    
    # Hook to apply token-based filtering before actions that need it
    # Only apply to actions that exist in the controller
    callback_actions = [:index, :active, :by_command, :active_by_command].select do |action|
      self.instance_methods(false).include?(action)
    end
    
    before_action :prepare_token_customer_filtering, only: callback_actions
  end

  class_methods do
    # Define which resources should be filtered by token customer
    def filter_by_token_customer(*resource_classes)
      self.token_filtered_resources = resource_classes.map(&:to_s)
    end
  end

  private

  # Store the current_customer in thread local storage for use in scopes
  def prepare_token_customer_filtering
    Thread.current[:current_customer] = current_customer if current_customer
  end

  # Override the apply_scopes method to automatically apply token-based filtering
  def apply_scopes(target)
    # Apply regular scopes first
    scoped = super
    
    # Get the target class name - handle both ActiveRecord::Relation and Class objects
    target_class_name = target.is_a?(Class) ? target.to_s : target.klass.to_s
    
    # If the target's class is in the list of token-filtered resources and customer_id is not explicitly provided
    if token_filtered_resources.include?(target_class_name) && !params[:customer_id].present?
      # Apply token-based customer filtering
      scoped = scoped.by_token_customer(current_customer) if scoped.respond_to?(:by_token_customer)
    end
    
    scoped
  end
end
