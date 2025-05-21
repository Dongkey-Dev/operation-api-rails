class Api::V1::RoomUsersController < ApplicationController
  before_action :set_api_v1_room_user, only: %i[ show update destroy ]

  # GET /api/v1/room_users
  def index
    @api_v1_room_users = Api::V1::RoomUser.all

    render json: @api_v1_room_users
  end

  # GET /api/v1/room_users/1
  def show
    render json: @api_v1_room_user
  end

  # POST /api/v1/room_users
  def create
    @api_v1_room_user = Api::V1::RoomUser.new(api_v1_room_user_params)

    if @api_v1_room_user.save
      render json: @api_v1_room_user, status: :created, location: @api_v1_room_user
    else
      render json: @api_v1_room_user.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/room_users/1
  def update
    if @api_v1_room_user.update(api_v1_room_user_params)
      render json: @api_v1_room_user
    else
      render json: @api_v1_room_user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/room_users/1
  def destroy
    @api_v1_room_user.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_api_v1_room_user
      @api_v1_room_user = Api::V1::RoomUser.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def api_v1_room_user_params
      params.expect(api_v1_room_user: [ :operationRoomId, :userId, :nickname, :role, :joinedAt, :leftAt ])
    end
end
