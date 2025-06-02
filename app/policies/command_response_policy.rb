class CommandResponsePolicy < ApplicationPolicy
  # Define who can view the list of command responses
  def index?
    # Admins can see all command responses
    # Regular users can only see responses for commands they have access to
    user.admin? || user_has_access_to_command_response?
  end

  # Define who can view a specific command response
  def show?
    # Admins can see any command response
    # Regular users can only see responses for commands they have access to
    user.admin? || user_has_access_to_command_response?
  end

  # Define who can create a command response
  def create?
    # Admins can create any command response
    # Regular users can only create responses for commands they can manage
    user.admin? || user_can_manage_command_response?
  end

  # Define who can update a command response
  def update?
    # Admins can update any command response
    # Regular users can only update responses for commands they can manage
    user.admin? || user_can_manage_command_response?
  end

  # Define who can delete a command response
  def destroy?
    # Admins can delete any command response
    # Regular users can only delete responses for commands they can manage
    user.admin? || user_can_manage_command_response?
  end

  # Define who can toggle active status
  def toggle_active?
    # Same permissions as update
    update?
  end

  # Scope for index action
  class Scope < Scope
    def resolve
      if user.admin?
        # Admins can see all command responses
        scope.where(is_deleted: false)
      else
        # Get commands owned by the user
        user_command_ids = Command.where(customer_id: user.id).pluck(:id)
        
        # Get rooms where user is a member
        member_room_ids = RoomUser.where(user_id: user.user_id).pluck(:operation_room_id)
        # Get commands in those rooms
        room_command_ids = Command.where(operation_room_id: member_room_ids).pluck(:id)
        
        # Combine both sets of command IDs
        accessible_command_ids = user_command_ids + room_command_ids
        
        # Get responses for those commands
        scope.where(command_id: accessible_command_ids, is_deleted: false)
      end
    end
  end

  private

  # Check if user has access to view the command response
  def user_has_access_to_command_response?
    # Get the associated command
    command = record.command
    return false unless command
    
    # Check if user owns the command
    is_owner = command.customer_id == user.id
    
    # Check if command belongs to a room where user is a member
    is_room_member = false
    if command.operation_room_id.present?
      is_room_member = RoomUser.exists?(operation_room_id: command.operation_room_id, user_id: user.user_id)
    end
    
    is_owner || is_room_member
  end

  # Check if user can manage (create/update/delete) the command response
  def user_can_manage_command_response?
    # Get the associated command
    command = record.command
    return false unless command
    
    # Check if user owns the command
    is_owner = command.customer_id == user.id
    
    # Check if command belongs to a room where user is an admin
    is_room_admin = false
    if command.operation_room_id.present?
      room = OperationRoom.find_by(id: command.operation_room_id)
      is_room_admin = room && room.customer_admin_user_id == user.id
    end
    
    is_owner || is_room_admin
  end
end
