class OperationRoom < ApplicationRecord
  include TokenScopable
  # Associations
  belongs_to :customer_admin_room, optional: true
  belongs_to :customer_admin_user, class_name: "Customer", optional: true
  has_many :chat_messages, dependent: :destroy
  has_many :commands, dependent: :destroy
  has_many :room_features, dependent: :destroy
  has_many :features, through: :room_features

  # Add serializable configuration for IncludableResources
  def self.includable_associations
    {
      room_features: { limit: 10 },
      features: { limit: 20 }
    }
  end
  has_many :room_plan_histories, dependent: :destroy
  has_many :plans, through: :room_plan_histories
  has_many :room_users, dependent: :destroy
  has_many :room_user_events, dependent: :destroy

  # Validations
  validates :chat_room_id, presence: true, uniqueness: { message: "is already associated with an operation room" }
  validates :platform_type, presence: true, length: { maximum: 20 }
  validates :room_type, presence: true, length: { maximum: 20 }

  # Scopes
  scope :by_platform, ->(platform_type) { where(platform_type: platform_type) }
  scope :by_room_type, ->(room_type) { where(room_type: room_type) }
  scope :by_customer_admin, ->(customer_id) { where(customer_admin_user_id: customer_id) }
  scope :by_admin_room, ->(admin_room_id) { where(customer_admin_room_id: admin_room_id) }
  scope :search_by_title, ->(title) { where("title LIKE ? OR origin_title LIKE ?", "%#{title}%", "%#{title}%") }
  scope :with_due_date_approaching, ->(days) { where("due_date <= ?", Time.current + days.days) }
  scope :with_due_date_passed, -> { where("due_date < ?", Time.current) }
  scope :ordered_by_created, -> { order(created_at: :desc) }
  scope :ordered_by_updated, -> { order(updated_at: :desc) }
  scope :ordered_by_payment, -> { order(accumulated_payment_amount: :desc) }

  # CRUD scopes
  scope :create_with_defaults, ->(attributes) {
    defaults = { accumulated_payment_amount: 0 }
    new(defaults.merge(attributes))
  }
  scope :find_by_id, ->(id) { find_by(id: id) }
  scope :find_by_chat_room_id, ->(chat_room_id) { find_by(chat_room_id: chat_room_id) }
  scope :update_title, ->(id, new_title) { find_by(id: id)&.update(title: new_title) }
  scope :update_due_date, ->(id, new_due_date) { find_by(id: id)&.update(due_date: new_due_date) }
  scope :update_payment_amount, ->(id, amount) {
    room = find_by(id: id)
    room&.update(accumulated_payment_amount: room.accumulated_payment_amount + amount)
  }

  # Callbacks
  before_validation :ensure_timestamps

  private

  def ensure_timestamps
    self.created_at ||= Time.current
    self.updated_at = Time.current if new_record? || changed?
  end
end
