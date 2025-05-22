class Api::V1::CustomerAdminRoomsController < ApplicationController
  before_action :set_customer_admin_room, only: %i[ show update destroy ]

  # GET /api/v1/customer_admin_rooms
  def index
    @customer_admin_rooms = CustomerAdminRoom.all

    render json: @customer_admin_rooms
  end

  # GET /api/v1/customer_admin_rooms/1
  def show
    render json: @customer_admin_room
  end

  # POST /api/v1/customer_admin_rooms
  def create
    @customer_admin_room = CustomerAdminRoom.new(customer_admin_room_params)

    if @customer_admin_room.save
      render json: @customer_admin_room, status: :created, location: @customer_admin_room
    else
      render json: @customer_admin_room.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/customer_admin_rooms/1
  def update
    if @customer_admin_room.update(customer_admin_room_params)
      render json: @customer_admin_room
    else
      render json: @customer_admin_room.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/customer_admin_rooms/1
  def destroy
    @customer_admin_room.destroy!
    render json: { message: "Customer admin room successfully deleted" }, status: :ok
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_customer_admin_room
      @customer_admin_room = CustomerAdminRoom.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def customer_admin_room_params
      params.expect(customer_admin_room: [ :admin_room_id, :customer_id, :is_active ])
    end
end
