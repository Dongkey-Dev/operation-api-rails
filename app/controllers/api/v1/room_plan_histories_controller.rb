class Api::V1::RoomPlanHistoriesController < ApplicationController
  before_action :set_api_v1_room_plan_history, only: %i[ show update destroy ]

  # GET /api/v1/room_plan_histories
  def index
    @api_v1_room_plan_histories = Api::V1::RoomPlanHistory.all

    render json: @api_v1_room_plan_histories
  end

  # GET /api/v1/room_plan_histories/1
  def show
    render json: @api_v1_room_plan_history
  end

  # POST /api/v1/room_plan_histories
  def create
    @api_v1_room_plan_history = Api::V1::RoomPlanHistory.new(api_v1_room_plan_history_params)

    if @api_v1_room_plan_history.save
      render json: @api_v1_room_plan_history, status: :created, location: @api_v1_room_plan_history
    else
      render json: @api_v1_room_plan_history.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/room_plan_histories/1
  def update
    if @api_v1_room_plan_history.update(api_v1_room_plan_history_params)
      render json: @api_v1_room_plan_history
    else
      render json: @api_v1_room_plan_history.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/room_plan_histories/1
  def destroy
    @api_v1_room_plan_history.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_api_v1_room_plan_history
      @api_v1_room_plan_history = Api::V1::RoomPlanHistory.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def api_v1_room_plan_history_params
      params.expect(api_v1_room_plan_history: [ :operationRoomId, :planId, :startDate, :endDate, :createdAt ])
    end
end
