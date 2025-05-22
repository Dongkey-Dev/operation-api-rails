class Plan < ApplicationRecord
  # Associations
  has_many :room_plan_histories, dependent: :destroy
  has_many :operation_rooms, through: :room_plan_histories

  # Validations
  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # Scopes
  scope :ordered_by_price, -> { order(price: :asc) }
  scope :ordered_by_name, -> { order(name: :asc) }
  scope :search_by_name, ->(name) { where("name LIKE ?", "%#{name}%") }
  scope :price_range, ->(min, max) { where(price: min..max) }

  # CRUD scopes
  scope :create_with_defaults, ->(attributes) { new(attributes) }
  scope :find_by_id, ->(id) { find_by(id: id) }
  scope :update_name, ->(id, new_name) { find_by(id: id)&.update(name: new_name) }
  scope :update_price, ->(id, new_price) { find_by(id: id)&.update(price: new_price) }
  scope :update_description, ->(id, new_description) { find_by(id: id)&.update(description: new_description) }
  scope :update_features, ->(id, new_features) { find_by(id: id)&.update(features: new_features) }

  # Callbacks
  before_validation :ensure_timestamps

  private

  def ensure_timestamps
    self.created_at ||= Time.current
    self.updated_at = Time.current if new_record? || changed?
  end
end
