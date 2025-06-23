class ChatMessage < ApplicationRecord
  include TokenScopable

  # Constants for period units
  VALID_PERIOD_UNITS = %w[day week month].freeze

  # Associations
  belongs_to :operation_room
  belongs_to :user, foreign_key: "user_id"

  # Validations
  validates :content, presence: true
  validates :operation_room_id, presence: true
  validates :user_id, presence: true

  # Scopes
  scope :created_between, ->(start_date, end_date) { where(created_at: start_date.beginning_of_day..end_date.end_of_day) }
  scope :by_operation_room, ->(operation_room_id) { where(operation_room_id: operation_room_id) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :latest, -> { order(created_at: :desc) }
  scope :oldest, -> { order(created_at: :asc) }

  # Period-based scopes
  scope :count_by_period, ->(period_unit, start_date, end_date) {
    raise ArgumentError, "Invalid period unit" unless VALID_PERIOD_UNITS.include?(period_unit)

    select("DATE_TRUNC('#{period_unit}', chat_messages.created_at AT TIME ZONE 'UTC') as period, COUNT(*) as count")
      .where(chat_messages: { created_at: start_date..end_date })
      .group("DATE_TRUNC('#{period_unit}', chat_messages.created_at AT TIME ZONE 'UTC')")
      .order("period ASC")
  }

  # CRUD scopes
  scope :create_with_defaults, ->(attributes) { new(attributes) }
  scope :find_by_id, ->(id) { find_by(_id: id) }
  scope :update_content, ->(id, new_content) { find_by(_id: id)&.update(content: new_content) }
  scope :delete_by_id, ->(id) { find_by(_id: id)&.destroy }

  # Callbacks
  before_validation :ensure_created_at

  private

  def ensure_created_at
    self.created_at ||= Time.current
  end
end
