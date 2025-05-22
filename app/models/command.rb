class Command < ApplicationRecord
  # Associations
  belongs_to :customer, optional: true
  belongs_to :operation_room, optional: true
  has_many :command_responses, dependent: :destroy

  # Validations
  validates :keyword, presence: true
  validate :customer_or_operation_room_present
  validate :unique_keyword_per_scope

  # Scopes
  scope :active, -> { where(is_active: true, is_deleted: false) }
  scope :inactive, -> { where(is_active: false) }
  scope :deleted, -> { where(is_deleted: true) }
  scope :by_customer, ->(customer_id) { where(customer_id: customer_id) }
  scope :by_operation_room, ->(operation_room_id) { where(operation_room_id: operation_room_id) }
  scope :search_by_keyword, ->(keyword) { where("keyword LIKE ?", "%#{keyword}%") }

  # CRUD scopes
  scope :create_with_defaults, ->(attributes) {
    defaults = { is_active: true, is_deleted: false }
    new(defaults.merge(attributes))
  }
  scope :find_by_id, ->(id) { find_by(id: id) }
  scope :update_keyword, ->(id, new_keyword) { find_by(id: id)&.update(keyword: new_keyword) }
  scope :update_description, ->(id, new_description) { find_by(id: id)&.update(description: new_description) }
  scope :activate, ->(id) { find_by(id: id)&.update(is_active: true) }
  scope :deactivate, ->(id) { find_by(id: id)&.update(is_active: false) }
  scope :mark_deleted, ->(id) { find_by(id: id)&.update(is_deleted: true, deleted_at: Time.current) }

  # Callbacks
  before_validation :ensure_timestamps

  private

  def ensure_timestamps
    self.created_at ||= Time.current
    self.updated_at = Time.current if new_record? || changed?
  end

  def customer_or_operation_room_present
    if customer_id.blank? && operation_room_id.blank?
      errors.add(:base, "Either customer or operation_room must be present")
    end
  end

  def unique_keyword_per_scope
    if customer_id.present?
      if Command.where(keyword: keyword, customer_id: customer_id)
              .where.not(id: id).exists?
        errors.add(:keyword, "already exists for this customer")
      end
    end

    if operation_room_id.present?
      if Command.where(keyword: keyword, operation_room_id: operation_room_id)
              .where.not(id: id).exists?
        errors.add(:keyword, "already exists for this operation room")
      end
    end
  end
end
