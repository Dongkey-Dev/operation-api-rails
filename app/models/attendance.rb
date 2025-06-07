class Attendance < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :operation_room, optional: true

  # Validations
  validates :user_id, presence: true

  # Scopes
  scope :by_operation_room, ->(operation_room_id) { where(operation_room_id: operation_room_id) if operation_room_id.present? }
  scope :by_user, ->(user_id) { where(user_id: user_id) if user_id.present? }

  # Cursor-based pagination support
  scope :created_before, ->(cursor_time) { where('created_at < ?', cursor_time) }
  scope :created_after, ->(cursor_time) { where('created_at > ?', cursor_time) }
end
