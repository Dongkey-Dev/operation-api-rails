class ChatMessagePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      return scope.none unless user.present?

      if user.respond_to?(:is_admin) && user.is_admin
        scope.all
      else
        # If user is a customer, only show messages from their operation rooms
        if user.is_a?(Customer)
          scope.joins(:operation_room)
               .joins("INNER JOIN customer_admin_rooms ON operation_rooms.id = customer_admin_rooms.admin_room_id")
               .where(customer_admin_rooms: { customer_id: user.id })
        else
          scope.none # For safety, return no records if user type is unknown
        end
      end
    end
  end

  def index?
    true
  end

  def show?
    record_belongs_to_user?
  end

  def create?
    record_belongs_to_user?
  end

  def update?
    record_belongs_to_user?
  end

  def destroy?
    record_belongs_to_user?
  end

  def counts_by_period?
    true
  end

  private

  def record_belongs_to_user?
    return false unless user.is_a?(Customer)

    CustomerAdminRoom.exists?(
      customer_id: user.id,
      operation_room_id: record.operation_room_id
    )
  end
end
