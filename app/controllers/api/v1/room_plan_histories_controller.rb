class Api::V1::RoomPlanHistoriesController < ApplicationController
  before_action :set_room_plan_history, only: %i[ show update destroy ]

  # GET /api/v1/room_plan_histories
  def index
    @room_plan_histories = RoomPlanHistory.all

    render json: @room_plan_histories
  end

  # GET /api/v1/room_plan_histories/1
  def show
    render json: @room_plan_history
  end

  # POST /api/v1/room_plan_histories
  def create
    @room_plan_history = RoomPlanHistory.new(room_plan_history_params)

    if @room_plan_history.save
      render json: @room_plan_history, status: :created, location: @room_plan_history
    else
      render json: @room_plan_history.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/room_plan_histories/1
  def update
    if @room_plan_history.update(room_plan_history_params)
      render json: @room_plan_history
    else
      render json: @room_plan_history.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/room_plan_histories/1
  def destroy
    @room_plan_history.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_room_plan_history
      @room_plan_history = RoomPlanHistory.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def room_plan_history_params
      params.expect(room_plan_history: [ :operationRoomId, :planId, :startDate, :endDate, :createdAt ])
    end
end
