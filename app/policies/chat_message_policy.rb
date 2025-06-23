class ChatMessagePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      return scope.none unless user.present?

      if user.respond_to?(:is_admin) && user.is_admin
        scope.all
      else
        # Customer가 운영하는 방들의 채팅 메시지만 조회
        if user.is_a?(Customer)
          scope.joins(:operation_room)
               .where(operation_rooms: { customer_admin_user_id: user.id })
        else
          scope.none # 안전을 위해 알 수 없는 사용자 타입은 빈 결과 반환
        end
      end
    end
  end

  def show?
    return true if user.respond_to?(:is_admin) && user.is_admin
    
    # Customer는 자신이 운영하는 방의 메시지만 볼 수 있음
    if user.is_a?(Customer)
      record.operation_room.customer_admin_user_id == user.id
    else
      false
    end
  end

  def index?
    user.present?
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
