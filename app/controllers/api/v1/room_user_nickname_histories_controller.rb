class Api::V1::RoomUserNicknameHistoriesController < ApplicationController
  before_action :set_api_v1_room_user_nickname_history, only: %i[ show update destroy ]

  # GET /api/v1/room_user_nickname_histories
  def index
    @api_v1_room_user_nickname_histories = Api::V1::RoomUserNicknameHistory.all

    render json: @api_v1_room_user_nickname_histories
  end

  # GET /api/v1/room_user_nickname_histories/1
  def show
    render json: @api_v1_room_user_nickname_history
  end

  # POST /api/v1/room_user_nickname_histories
  def create
    @api_v1_room_user_nickname_history = Api::V1::RoomUserNicknameHistory.new(api_v1_room_user_nickname_history_params)

    if @api_v1_room_user_nickname_history.save
      render json: @api_v1_room_user_nickname_history, status: :created, location: @api_v1_room_user_nickname_history
    else
      render json: @api_v1_room_user_nickname_history.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/room_user_nickname_histories/1
  def update
    if @api_v1_room_user_nickname_history.update(api_v1_room_user_nickname_history_params)
      render json: @api_v1_room_user_nickname_history
    else
      render json: @api_v1_room_user_nickname_history.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/room_user_nickname_histories/1
  def destroy
    @api_v1_room_user_nickname_history.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_api_v1_room_user_nickname_history
      @api_v1_room_user_nickname_history = Api::V1::RoomUserNicknameHistory.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def api_v1_room_user_nickname_history_params
      params.expect(api_v1_room_user_nickname_history: [ :chatRoomId, :userId, :previousNickname, :newNickname, :createdAt, :isDeleted, :deletedAt ])
    end
end
