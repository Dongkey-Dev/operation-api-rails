class Feature < ApplicationRecord
  # Associations
  has_many :room_features, dependent: :destroy
  has_many :operation_rooms, through: :room_features

  # Validations
  validates :name, presence: true

  # Scopes
  scope :search_by_name, ->(name) { where("name LIKE ?", "%#{name}%") }
  scope :with_description, -> { where.not(description: [nil, '']) }
  scope :ordered_by_name, -> { order(name: :asc) }
  scope :ordered_by_created, -> { order(created_at: :desc) }

  # CRUD scopes
  scope :create_with_defaults, ->(attributes) { new(attributes) }
  scope :find_by_id, ->(id) { find_by(id: id) }
  scope :update_name, ->(id, new_name) { find_by(id: id)&.update(name: new_name) }
  scope :update_description, ->(id, new_description) { find_by(id: id)&.update(description: new_description) }

  # Callbacks
  before_validation :ensure_timestamps

  private

  def ensure_timestamps
    self.created_at ||= Time.current
    self.updated_at = Time.current if new_record? || changed?
  end
end
