class CommandPolicy < ApplicationPolicy
  # Define who can view the list of commands
  def index?
    # Admins can see all commands
    # Regular users can only see commands they own or commands in rooms they are members of
    user.admin? || user_has_access_to_command?
  end

  # Define who can view a specific command
  def show?
    # Admins can see any command
    # Regular users can only see commands they own or commands in rooms they are members of
    user.admin? || user_has_access_to_command?
  end

  # Define who can create a command
  def create?
    # Admins can create any command
    # Regular users can only create commands for themselves or for rooms they are admin of
    user.admin? || user_can_manage_command?
  end

  # Define who can update a command
  def update?
    # Admins can update any command
    # Regular users can only update commands they own or commands in rooms they are admin of
    user.admin? || user_can_manage_command?
  end

  # Define who can delete a command
  def destroy?
    # Admins can delete any command
    # Regular users can only delete commands they own or commands in rooms they are admin of
    user.admin? || user_can_manage_command?
  end

  # Scope for index action
  class Scope < Scope
    def resolve
      if user.admin?
        # Admins can see all commands
        scope.all
      else
        # Get commands owned by the user
        user_commands = scope.where(customer_id: user.id)
        
        # Get rooms where user is a member
        member_room_ids = RoomUser.where(user_id: user.user_id).pluck(:operation_room_id)
        # Get commands in those rooms
        room_commands = scope.where(operation_room_id: member_room_ids)
        
        # Combine both sets of commands
        user_commands.or(room_commands)
      end
    end
  end

  private

  # Check if user has access to view the command
  def user_has_access_to_command?
    # Check if user owns the command
    is_owner = record.customer_id == user.id
    
    # Check if command belongs to a room where user is a member
    is_room_member = false
    if record.operation_room_id.present?
      is_room_member = RoomUser.exists?(operation_room_id: record.operation_room_id, user_id: user.user_id)
    end
    
    is_owner || is_room_member
  end

  # Check if user can manage (create/update/delete) the command
  def user_can_manage_command?
    # Check if user owns the command
    is_owner = record.customer_id == user.id
    
    # Check if command belongs to a room where user is an admin
    is_room_admin = false
    if record.operation_room_id.present?
      room = OperationRoom.find_by(id: record.operation_room_id)
      is_room_admin = room && room.customer_admin_user_id == user.id
    end
    
    is_owner || is_room_admin
  end
end
