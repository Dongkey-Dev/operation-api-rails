class CustomerPolicy < ApplicationPolicy
  # Define who can view the list of customers
  def index?
    # Only admins can see all customers
    user.admin?
  end

  # Define who can view a specific customer
  def show?
    # Admins can see any customer
    # Users can only see their own customer record
    user.admin? || user.id == record.id
  end

  # Define who can create a customer
  def create?
    # Only admins can create customers
    user.admin?
  end

  # Define who can update a customer
  def update?
    # Admins can update any customer
    # Users can only update their own customer record
    user.admin? || user.id == record.id
  end

  # Define who can delete a customer
  def destroy?
    # Only admins can delete customers
    user.admin?
  end

  # Define custom policy for by_user_id action
  def by_user_id?
    # Admins can look up any customer
    # Users can only look up their own customer record
    user.admin? || user.user_id.to_s == params[:user_id].to_s
  end

  # Define custom policy for by_email action
  def by_email?
    # Admins can look up any customer
    # Users can only look up their own customer record
    user.admin? || user.email.downcase == params[:email].downcase
  end

  # Scope for index action
  class Scope < Scope
    def resolve
      if user.admin?
        # Admins can see all customers
        scope.all
      else
        # Regular users can only see their own customer record
        scope.where(id: user.id)
      end
    end
  end

  private

  def params
    # Access controller params
    @params ||= @context[:params] || {}
  end
end
