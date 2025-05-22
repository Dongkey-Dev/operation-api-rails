class ChatMessage < ApplicationRecord
  # Associations
  belongs_to :operation_room
  belongs_to :user, foreign_key: "user_id"

  # Validations
  validates :content, presence: true
  validates :operation_room_id, presence: true
  validates :user_id, presence: true

  # Scopes
  scope :created_between, ->(start_date, end_date) { where(created_at: start_date..end_date) }
  scope :by_operation_room, ->(operation_room_id) { where(operation_room_id: operation_room_id) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :latest, -> { order(created_at: :desc) }
  scope :oldest, -> { order(created_at: :asc) }

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
