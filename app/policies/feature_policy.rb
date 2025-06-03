# frozen_string_literal: true

class FeaturePolicy < ApplicationPolicy
  # Index and show actions are allowed for all authenticated users (both customers and admins)
  def index?
    user.present?
  end

  def show?
    user.present?
  end

  # Create, update, and destroy actions are only allowed for admin users
  def create?
    user.present? && user.admin?
  end

  def update?
    user.present? && user.admin?
  end

  def destroy?
    user.present? && user.admin?
  end

  # Define which records can be accessed by the user
  class Scope < Scope
    def resolve
      # All features are visible to authenticated users
      scope.all
    end
  end
end
