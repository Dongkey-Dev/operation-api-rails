class RoomUserNicknameHistory < ApplicationRecord
  # Associations
  # Note: Using chat_room_id instead of operation_room_id based on schema

  # Validations
  validates :chat_room_id, presence: true
  validates :user_id, presence: true
  validates :new_nickname, presence: true

  # Scopes
  scope :by_chat_room, ->(chat_room_id) { where(chat_room_id: chat_room_id) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :not_deleted, -> { where(is_deleted: false) }
  scope :deleted, -> { where(is_deleted: true) }
  scope :ordered_by_created, -> { order(created_at: :desc) }

  # CRUD scopes
  scope :create_with_defaults, ->(attributes) {
    defaults = { is_deleted: false }
    new(defaults.merge(attributes))
  }
  scope :find_by_id, ->(id) { find_by(id: id) }
  scope :find_latest_for_user_in_room, ->(user_id, chat_room_id) {
    where(user_id: user_id, chat_room_id: chat_room_id, is_deleted: false)
      .order(created_at: :desc)
      .first
  }
  scope :mark_deleted, ->(id) { find_by(id: id)&.update(is_deleted: true, deleted_at: Time.current) }

  # Callbacks
  before_validation :ensure_created_at

  private

  def ensure_created_at
    self.created_at ||= Time.current
  end
end
