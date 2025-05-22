class RoomFeature < ApplicationRecord
  # Associations
  belongs_to :operation_room
  belongs_to :feature

  # Validations
  validates :operation_room_id, presence: true
  validates :feature_id, presence: true
  validates :feature_id, uniqueness: { scope: :operation_room_id, message: 'is already enabled for this room' }

  # Scopes
  scope :active, -> { where(is_active: true) }
  scope :inactive, -> { where(is_active: false) }
  scope :by_operation_room, ->(operation_room_id) { where(operation_room_id: operation_room_id) }
  scope :by_feature, ->(feature_id) { where(feature_id: feature_id) }

  # CRUD scopes
  scope :create_with_defaults, ->(attributes) { 
    defaults = { is_active: true }
    new(defaults.merge(attributes))
  }
  scope :find_by_id, ->(id) { find_by(id: id) }
  scope :find_by_room_and_feature, ->(room_id, feature_id) { 
    find_by(operation_room_id: room_id, feature_id: feature_id)
  }
  scope :activate, ->(id) { find_by(id: id)&.update(is_active: true) }
  scope :deactivate, ->(id) { find_by(id: id)&.update(is_active: false) }

  # Callbacks
  before_validation :ensure_timestamps

  private

  def ensure_timestamps
    self.created_at ||= Time.current
    self.updated_at = Time.current if new_record? || changed?
  end
end
