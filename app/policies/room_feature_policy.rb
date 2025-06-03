# frozen_string_literal: true

class RoomFeaturePolicy < ApplicationPolicy
  # Index and show actions are allowed for all authenticated users (both customers and admins)
  def index?
    user.present?
  end

  def show?
    user.present?
  end

  # Create, update, and destroy actions are allowed for customers who own the operation room
  # or for admin users
  def create?
    return true if user.present? && user.admin?
    
    # Check if the user is authorized for the operation room
    if user.present? && record.operation_room_id.present?
      operation_room = OperationRoom.find_by(id: record.operation_room_id)
      return operation_room && operation_room.customer_admin_user_id == user.id
    end
    
    false
  end

  def update?
    return true if user.present? && user.admin?
    
    # Check if the user is authorized for the operation room
    if user.present? && record.operation_room.present?
      return record.operation_room.customer_admin_user_id == user.id
    end
    
    false
  end

  def destroy?
    return true if user.present? && user.admin?
    
    # Check if the user is authorized for the operation room
    if user.present? && record.operation_room.present?
      return record.operation_room.customer_admin_user_id == user.id
    end
    
    false
  end

  # Define which records can be accessed by the user
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        # Return room features for operation rooms owned by the user
        scope.joins(:operation_room).where(operation_rooms: { customer_admin_user_id: user.id })
      end
    end
  end
end
