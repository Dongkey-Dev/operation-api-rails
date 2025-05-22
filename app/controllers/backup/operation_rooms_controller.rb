class Api::V1::OperationRoomsController < ApplicationController
  before_action :set_api_v1_operation_room, only: %i[ show update destroy ]

  # GET /api/v1/operation_rooms
  def index
    @api_v1_operation_rooms = Api::V1::OperationRoom.all

    render json: @api_v1_operation_rooms
  end

  # GET /api/v1/operation_rooms/1
  def show
    render json: @api_v1_operation_room
  end

  # POST /api/v1/operation_rooms
  def create
    @api_v1_operation_room = Api::V1::OperationRoom.new(api_v1_operation_room_params)

    if @api_v1_operation_room.save
      render json: @api_v1_operation_room, status: :created, location: @api_v1_operation_room
    else
      render json: @api_v1_operation_room.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/operation_rooms/1
  def update
    if @api_v1_operation_room.update(api_v1_operation_room_params)
      render json: @api_v1_operation_room
    else
      render json: @api_v1_operation_room.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/operation_rooms/1
  def destroy
    @api_v1_operation_room.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_api_v1_operation_room
      @api_v1_operation_room = Api::V1::OperationRoom.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def api_v1_operation_room_params
      params.expect(api_v1_operation_room: [ :chatRoomId, :openChatLink, :originTitle, :title, :accumulatedPaymentAmount, :platformType, :roomType, :customerAdminRoomId, :customerAdminUserId, :dueDate, :createdAt, :updatedAt ])
    end
end
