class OperationRoomPolicy < ApplicationPolicy
  # Define who can view the list of operation rooms
  def index?
    # Admins can see all operation rooms
    # Regular users can only see operation rooms they are members of or admin of
    user.admin? || user_has_access_to_room?
  end

  # Define who can view a specific operation room
  def show?
    # Admins can see any operation room
    # Regular users can only see operation rooms they are members of or admin of
    user.admin? || user_has_access_to_room?
  end

  # Define who can create an operation room
  def create?
    # Only admins can create operation rooms
    user.admin?
  end

  # Define who can update an operation room
  def update?
    # Admins can update any operation room
    # Regular users can only update operation rooms they are admin of
    user.admin? || user_is_room_admin?
  end

  # Define who can delete an operation room
  def destroy?
    # Only admins can delete operation rooms
    user.admin?
  end

  # Scope for index action
  class Scope < Scope
    def resolve
      if user.admin?
        # Admins can see all operation rooms
        scope.all
      else
        # Regular users can only see operation rooms they are members of or admin of
        # Get rooms where user is a member
        member_room_ids = RoomUser.where(user_id: user.user_id).pluck(:operation_room_id)
        # Get rooms where user is an admin
        admin_room_ids = scope.where(customer_admin_user_id: user.id).pluck(:id)
        # Combine both sets of room IDs
        accessible_room_ids = (member_room_ids + admin_room_ids).uniq
        # Return only those rooms
        scope.where(id: accessible_room_ids)
      end
    end
  end

  private

  # Check if user is a member or admin of the room
  def user_has_access_to_room?
    # Check if user is a member of the room
    is_member = RoomUser.exists?(operation_room_id: record.id, user_id: user.user_id)
    # Check if user is an admin of the room
    is_admin = record.customer_admin_user_id == user.id
    
    is_member || is_admin
  end

  # Check if user is an admin of the room
  def user_is_room_admin?
    record.customer_admin_user_id == user.id
  end
end
