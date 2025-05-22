class Api::V1::RoomUsersController < ApplicationController
  before_action :set_room_user, only: %i[ show update destroy ]

  # Define scopes that can be used for filtering
  has_scope :active, type: :boolean
  has_scope :inactive, type: :boolean
  has_scope :by_operation_room
  has_scope :by_user
  has_scope :by_role
  has_scope :joined_between
  has_scope :left_between
  has_scope :ordered_by_joined

  # GET /api/v1/room_users
  def index
    # Validate and transform parameters
    param! :limit, Integer, default: 20, min: 1, max: 100
    param! :cursor, Integer, default: 1, min: 1
    param! :sortBy, String, in: %w[role active created_at updated_at], required: false
    param! :sortOrder, String, in: %w[asc desc], default: 'asc'

    # Get pagination params and build base query
    pagination = pagination_params
    base_query = apply_scopes(RoomUser)

    if pagination[:sort_by].present?
      base_query = base_query.order(pagination[:sort_by] => pagination[:sort_order])
    end

    # Apply Pagy pagination
    pagination = pagination_params
    @pagy, @room_users = pagy(base_query, items: pagination[:items])

    # Calculate next cursor
    next_cursor = @pagy.page < @pagy.pages ? @pagy.page + 1 : nil

    # Render response with pagination metadata
    render json: {
      data: @room_users,
      pagination: {
        limit: @pagy.items,
        total: @pagy.count,
        next_cursor: next_cursor
      }
    }
  end

  # GET /api/v1/room_users/1
  def show
    render json: @room_user
  end

  # POST /api/v1/room_users
  def create
    @room_user = RoomUser.new(room_user_params)

    if @room_user.save
      render json: @room_user, status: :created, location: @room_user
    else
      render json: @room_user.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/room_users/1
  def update
    if @room_user.update(room_user_params)
      render json: @room_user
    else
      render json: @room_user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/room_users/1
  def destroy
    @room_user.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_room_user
      @room_user = RoomUser.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def  room_user_params
      params.expect(room_user: [ :operationRoomId, :userId, :nickname, :role, :joinedAt, :leftAt ])
    end
end
