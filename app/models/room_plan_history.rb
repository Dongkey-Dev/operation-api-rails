class RoomPlanHistory < ApplicationRecord
  # Associations
  belongs_to :operation_room
  belongs_to :plan

  # Validations
  validates :operation_room_id, presence: true
  validates :plan_id, presence: true
  validates :start_date, presence: true
  validate :end_date_after_start_date, if: -> { end_date.present? }

  # Scopes
  scope :active, -> { where('end_date IS NULL OR end_date > ?', Time.current) }
  scope :expired, -> { where('end_date IS NOT NULL AND end_date <= ?', Time.current) }
  scope :by_operation_room, ->(operation_room_id) { where(operation_room_id: operation_room_id) }
  scope :by_plan, ->(plan_id) { where(plan_id: plan_id) }
  scope :started_between, ->(start_date, end_date) { where(start_date: start_date..end_date) }
  scope :ended_between, ->(start_date, end_date) { where(end_date: start_date..end_date) }
  scope :ordered_by_start_date, -> { order(start_date: :desc) }

  # CRUD scopes
  scope :create_with_defaults, ->(attributes) { new(attributes) }
  scope :find_by_id, ->(id) { find_by(id: id) }
  scope :find_active_for_room, ->(room_id) { 
    where(operation_room_id: room_id)
      .where('end_date IS NULL OR end_date > ?', Time.current)
      .order(start_date: :desc)
      .first
  }
  scope :update_end_date, ->(id, new_end_date) { find_by(id: id)&.update(end_date: new_end_date) }

  # Callbacks
  before_validation :ensure_created_at

  private

  def ensure_created_at
    self.created_at ||= Time.current
  end

  def end_date_after_start_date
    if end_date <= start_date
      errors.add(:end_date, 'must be after start date')
    end
  end
end
