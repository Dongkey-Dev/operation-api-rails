class Customer < ApplicationRecord
  # Associations
  has_many :commands, dependent: :destroy
  has_many :customer_admin_rooms, dependent: :destroy
  has_many :admin_rooms, class_name: "OperationRoom", foreign_key: "customer_admin_user_id", dependent: :nullify
  has_many :room_users, foreign_key: "user_id", primary_key: "user_id", dependent: :destroy
  has_many :member_operation_rooms, through: :room_users, source: :operation_room
  
  # Callbacks
  before_create :generate_token
  
  # Authorization methods
  def admin?
    is_admin
  end
  
  # Token management
  def generate_token
    self.token = loop do
      random_token = SecureRandom.urlsafe_base64(32)
      break random_token unless Customer.exists?(token: random_token)
    end
  end
  
  def regenerate_token!
    generate_token
    save!
    token
  end

  # We can't use a direct has_many association for operation_rooms because we need to combine two different
  # sources of rooms. Instead, we'll modify the CustomersController to handle this special case.

  # Validations
  validates :user_id, presence: true, uniqueness: { message: "is already associated with a customer" }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true }

  # Scopes
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :search_by_name, ->(name) { where("name LIKE ?", "%#{name}%") }
  scope :search_by_email, ->(email) { where("email LIKE ?", "%#{email}%") }
  scope :with_recent_login, ->(days) { where("last_login_at > ?", Time.current - days.days) }

  # CRUD scopes
  scope :create_with_defaults, ->(attributes) { new(attributes) }
  scope :find_by_id, ->(id) { find_by(id: id) }
  scope :find_by_user_id, ->(user_id) { find_by(user_id: user_id) }
  scope :update_name, ->(id, new_name) { find_by(id: id)&.update(name: new_name) }
  scope :update_email, ->(id, new_email) { find_by(id: id)&.update(email: new_email) }
  scope :update_phone, ->(id, new_phone) { find_by(id: id)&.update(phone_number: new_phone) }
  scope :update_password, ->(id, new_password) { find_by(id: id)&.update(password: new_password) }
  scope :record_login, ->(id) { find_by(id: id)&.update(last_login_at: Time.current) }

  # Callbacks
  before_validation :ensure_timestamps

  private

  def ensure_timestamps
    self.created_at ||= Time.current
    self.updated_at = Time.current if new_record? || changed?
  end
end
