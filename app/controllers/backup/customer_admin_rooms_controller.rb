class CustomerAdminRoomsController < ApplicationController
  before_action :set_api_v1_customer_admin_room, only: %i[ show update destroy ]

  # GET /api/v1/customer_admin_rooms
  def index
    @api_v1_customer_admin_rooms = CustomerAdminRoom.all

    render json: @api_v1_customer_admin_rooms
  end

  # GET /api/v1/customer_admin_rooms/1
  def show
    render json: @api_v1_customer_admin_room
  end

  # POST /api/v1/customer_admin_rooms
  def create
    @api_v1_customer_admin_room = CustomerAdminRoom.new(api_v1_customer_admin_room_params)

    if @api_v1_customer_admin_room.save
      render json: @api_v1_customer_admin_room, status: :created, location: @api_v1_customer_admin_room
    else
      render json: @api_v1_customer_admin_room.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/customer_admin_rooms/1
  def update
    if @api_v1_customer_admin_room.update(api_v1_customer_admin_room_params)
      render json: @api_v1_customer_admin_room
    else
      render json: @api_v1_customer_admin_room.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/customer_admin_rooms/1
  def destroy
    @api_v1_customer_admin_room.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_api_v1_customer_admin_room
      @api_v1_customer_admin_room = CustomerAdminRoom.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def api_v1_customer_admin_room_params
      params.expect(api_v1_customer_admin_room: [ :adminRoomId, :customerId, :isActive, :createdAt ])
    end
end
