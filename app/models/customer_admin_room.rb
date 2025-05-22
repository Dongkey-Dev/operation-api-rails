class CustomerAdminRoom < ApplicationRecord
  # Associations
  belongs_to :customer
  has_many :operation_rooms, dependent: :nullify

  # Validations
  validates :admin_room_id, presence: true, uniqueness: { message: 'is already assigned to a customer' }
  validates :customer_id, presence: true

  # Scopes
  scope :active, -> { where(is_active: true) }
  scope :inactive, -> { where(is_active: false) }
  scope :by_customer, ->(customer_id) { where(customer_id: customer_id) }
  scope :by_admin_room, ->(admin_room_id) { where(admin_room_id: admin_room_id) }

  # CRUD scopes
  scope :create_with_defaults, ->(attributes) { 
    defaults = { is_active: true }
    new(defaults.merge(attributes))
  }
  scope :find_by_id, ->(id) { find_by(id: id) }
  scope :find_by_admin_room_id, ->(admin_room_id) { find_by(admin_room_id: admin_room_id) }
  scope :activate, ->(id) { find_by(id: id)&.update(is_active: true) }
  scope :deactivate, ->(id) { find_by(id: id)&.update(is_active: false) }

  # Callbacks
  before_validation :ensure_created_at

  private

  def ensure_created_at
    self.created_at ||= Time.current
  end
end
