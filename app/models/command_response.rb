class CommandResponse < ApplicationRecord
  # Associations
  belongs_to :command

  # Validations
  validates :content, presence: true
  validates :command_id, presence: true
  validates :response_type, presence: true, length: { maximum: 20 }

  # Scopes
  scope :active, -> { where(is_active: true, is_deleted: false) }
  scope :inactive, -> { where(is_active: false) }
  scope :deleted, -> { where(is_deleted: true) }
  scope :by_type, ->(response_type) { where(response_type: response_type) }
  scope :by_priority, ->(priority) { where(priority: priority) }
  scope :ordered_by_priority, -> { order(priority: :desc) }
  scope :by_command, ->(command_id) { where(command_id: command_id) }

  # CRUD scopes
  scope :create_with_defaults, ->(attributes) {
    defaults = { response_type: "text", priority: 0, is_active: true, is_deleted: false }
    new(defaults.merge(attributes))
  }
  scope :find_by_id, ->(id) { find_by(id: id) }
  scope :update_content, ->(id, new_content) { find_by(id: id)&.update(content: new_content) }
  scope :update_priority, ->(id, new_priority) { find_by(id: id)&.update(priority: new_priority) }
  scope :activate, ->(id) { find_by(id: id)&.update(is_active: true) }
  scope :deactivate, ->(id) { find_by(id: id)&.update(is_active: false) }
  scope :mark_deleted, ->(id) { find_by(id: id)&.update(is_deleted: true, deleted_at: Time.current) }

  # Callbacks
  before_validation :ensure_timestamps
  before_save :set_default_values

  private

  def ensure_timestamps
    self.created_at ||= Time.current
    self.updated_at = Time.current if new_record? || changed?
  end

  def set_default_values
    self.response_type ||= "text"
    self.priority ||= 0
    self.is_active = true if is_active.nil?
    self.is_deleted = false if is_deleted.nil?
  end
end
