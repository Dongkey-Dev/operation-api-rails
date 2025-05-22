class RoomUser < ApplicationRecord
  # Associations
  belongs_to :operation_room
  belongs_to :user, foreign_key: 'user_id'

  # Validations
  validates :operation_room_id, presence: true
  validates :user_id, presence: true
  validates :role, presence: true, length: { maximum: 20 }
  validates :user_id, uniqueness: { scope: :operation_room_id, message: 'is already a member of this room' }

  # Scopes
  scope :active, -> { where(left_at: nil) }
  scope :inactive, -> { where.not(left_at: nil) }
  scope :by_operation_room, ->(operation_room_id) { where(operation_room_id: operation_room_id) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :by_role, ->(role) { where(role: role) }
  scope :joined_between, ->(start_date, end_date) { where(joined_at: start_date..end_date) }
  scope :left_between, ->(start_date, end_date) { where(left_at: start_date..end_date) }
  scope :ordered_by_joined, -> { order(joined_at: :desc) }

  # CRUD scopes
  scope :create_with_defaults, ->(attributes) { 
    defaults = { joined_at: Time.current }
    new(defaults.merge(attributes))
  }
  scope :find_by_id, ->(id) { find_by(id: id) }
  scope :find_by_user_and_room, ->(user_id, room_id) { 
    find_by(user_id: user_id, operation_room_id: room_id)
  }
  scope :update_nickname, ->(id, new_nickname) { find_by(id: id)&.update(nickname: new_nickname) }
  scope :update_role, ->(id, new_role) { find_by(id: id)&.update(role: new_role) }
  scope :mark_left, ->(id) { find_by(id: id)&.update(left_at: Time.current) }

  # Constants
  ROLES = %w[admin moderator member guest].freeze

  # Callbacks
  before_validation :ensure_joined_at
  validate :validate_role

  private

  def ensure_joined_at
    self.joined_at ||= Time.current
  end

  def validate_role
    unless ROLES.include?(role)
      errors.add(:role, 'is not a valid role')
    end
  end
end
