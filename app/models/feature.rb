class Feature < ApplicationRecord
  # Associations
  has_many :room_features, dependent: :destroy
  has_many :operation_rooms, through: :room_features

  # Add serializable configuration for IncludableResources
  def self.includable_associations
    {
      room_features: { limit: 10 }
    }
  end

  # Override as_json to include associations when requested
  def as_json(options = {})
    options ||= {}

    # Start with default attributes
    json = super(options.except(:include))

    # Handle includes if present
    if options[:include].present?
      includes = options[:include].is_a?(Hash) ? options[:include].keys :
                options[:include].is_a?(Array) ? options[:include] :
                [ options[:include] ]

      # Include room_features if requested
      if includes.map(&:to_s).include?("room_features")
        json["room_features"] = room_features.map { |rf| rf.as_json(options.except(:include)) }
      end

      # Include operation_rooms if requested
      if includes.map(&:to_s).include?("operation_rooms")
        json["operation_rooms"] = operation_rooms.map { |op_room| op_room.as_json(options.except(:include)) }
      end
    end

    json
  end

  # Validations
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :category, presence: true

  # Scopes
  scope :search_by_name, ->(name) { where("name LIKE ?", "%#{name}%") }
  scope :with_description, -> { where.not(description: [ nil, "" ]) }
  scope :by_category, ->(category) { where(category: category) }
  scope :ordered_by_name, -> { order(name: :asc) }
  scope :ordered_by_created, -> { order(created_at: :desc) }

  # CRUD scopes
  scope :create_with_defaults, ->(attributes) { new(attributes) }
  scope :find_by_id, ->(id) { find_by(id: id) }
  scope :update_name, ->(id, new_name) { find_by(id: id)&.update(name: new_name) }
  scope :update_description, ->(id, new_description) { find_by(id: id)&.update(description: new_description) }
  scope :update_category, ->(id, new_category) { find_by(id: id)&.update(category: new_category) }

  # Callbacks
  before_validation :ensure_timestamps

  private

  def ensure_timestamps
    self.created_at ||= Time.current
    self.updated_at = Time.current if new_record? || changed?
  end
end
