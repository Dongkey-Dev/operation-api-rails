class Api::V1::OperationRoomsController < ApplicationController
  before_action :set_operation_room, only: %i[ show update destroy ]

  # Define scopes that can be used for filtering
  has_scope :by_platform
  has_scope :by_room_type
  has_scope :by_customer_admin
  has_scope :by_admin_room
  has_scope :search_by_title
  has_scope :with_due_date_approaching
  has_scope :ordered_by_created
  has_scope :ordered_by_updated
  has_scope :ordered_by_payment

  # GET /api/v1/operation_rooms
  def index
    # Validate and transform parameters
    param! :limit, Integer, default: 15, min: 1, max: 100
    param! :cursor, Integer, default: 1, min: 1
    param! :sortBy, String, in: %w[platform room_type created_at updated_at], required: false
    param! :sortOrder, String, in: %w[asc desc], default: 'asc'

    # Get pagination params and build base query
    pagination = pagination_params
    base_query = apply_scopes(OperationRoom)

    if pagination[:sort_by].present?
      base_query = base_query.order(pagination[:sort_by] => pagination[:sort_order])
    end

    # Apply Pagy pagination
    pagination = pagination_params
    @pagy, @operation_rooms = pagy(base_query, items: pagination[:items])

    # Calculate next cursor
    next_cursor = @pagy.page < @pagy.pages ? @pagy.page + 1 : nil

    # Render response with pagination metadata
    render json: {
      data: @operation_rooms,
      pagination: {
        limit: @pagy.items,
        total: @pagy.count,
        next_cursor: next_cursor
      }
    }
  end

  # GET /api/v1/operation_rooms/1
  def show
    render json: @operation_room
  end

  # POST /api/v1/operation_rooms
  def create
    @operation_room = OperationRoom.new(operation_room_params)

    if @operation_room.save
      render json: @operation_room, status: :created, location: @operation_room
    else
      render json: @operation_room.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/operation_rooms/1
  def update
    if @operation_room.update(operation_room_params)
      render json: @operation_room
    else
      render json: @operation_room.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/operation_rooms/1
  def destroy
    @operation_room.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_operation_room
      @operation_room = OperationRoom.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def operation_room_params
      params.expect(operation_room: [ :chatRoomId, :openChatLink, :originTitle, :title, :accumulatedPaymentAmount, :platformType, :roomType, :customerAdminRoomId, :customerAdminUserId, :dueDate, :createdAt, :updatedAt ])
    end
end
