class Api::V1::RoomUserNicknameHistoriesController < ApplicationController
  before_action :set_room_user_nickname_history, only: %i[ show update destroy ]

  # GET /api/v1/room_user_nickname_histories
  def index
    @room_user_nickname_histories = RoomUserNicknameHistory.all

    render json: @room_user_nickname_histories
  end

  # GET /api/v1/room_user_nickname_histories/1
  def show
    render json: @room_user_nickname_history
  end

  # POST /api/v1/room_user_nickname_histories
  def create
    @room_user_nickname_history = RoomUserNicknameHistory.new(room_user_nickname_history_params)

    if @room_user_nickname_history.save
      render json: @room_user_nickname_history, status: :created, location: @room_user_nickname_history
    else
      render json: @room_user_nickname_history.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/room_user_nickname_histories/1
  def update
    if @room_user_nickname_history.update(room_user_nickname_history_params)
      render json: @room_user_nickname_history
    else
      render json: @room_user_nickname_history.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/room_user_nickname_histories/1
  def destroy
    @room_user_nickname_history.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_room_user_nickname_history
      @room_user_nickname_history = RoomUserNicknameHistory.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def room_user_nickname_history_params
      params.expect(room_user_nickname_history: [ :chatRoomId, :userId, :previousNickname, :newNickname, :createdAt, :isDeleted, :deletedAt ])
    end
end
