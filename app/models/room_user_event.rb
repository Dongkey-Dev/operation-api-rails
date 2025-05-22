class RoomUserEvent < ApplicationRecord
  # Associations
  belongs_to :operation_room
  belongs_to :user, foreign_key: "user_id"

  # Validations
  validates :operation_room_id, presence: true
  validates :user_id, presence: true
  validates :event_type, presence: true, length: { maximum: 10 }

  # Scopes
  scope :by_operation_room, ->(operation_room_id) { where(operation_room_id: operation_room_id) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :by_event_type, ->(event_type) { where(event_type: event_type) }
  scope :events_between, ->(start_date, end_date) { where(event_at: start_date..end_date) }
  scope :latest_events, ->(limit = 10) { order(event_at: :desc).limit(limit) }

  # CRUD scopes
  scope :create_with_defaults, ->(attributes) {
    defaults = { event_at: Time.current }
    new(defaults.merge(attributes))
  }
  scope :find_by_id, ->(id) { find_by(id: id) }
  scope :find_latest_by_user_and_room, ->(user_id, room_id) {
    where(user_id: user_id, operation_room_id: room_id)
      .order(event_at: :desc)
      .first
  }

  # Constants
  EVENT_TYPES = %w[join leave message reaction].freeze

  # Callbacks
  before_validation :ensure_event_at
  validate :validate_event_type

  private

  def ensure_event_at
    self.event_at ||= Time.current
  end

  def validate_event_type
    unless EVENT_TYPES.include?(event_type)
      errors.add(:event_type, "is not a valid event type")
    end
  end
end
