class Api::V1::RoomUserEventsController < ApplicationController
  before_action :set_api_v1_room_user_event, only: %i[ show update destroy ]

  # GET /api/v1/room_user_events
  def index
    @api_v1_room_user_events = Api::V1::RoomUserEvent.all

    render json: @api_v1_room_user_events
  end

  # GET /api/v1/room_user_events/1
  def show
    render json: @api_v1_room_user_event
  end

  # POST /api/v1/room_user_events
  def create
    @api_v1_room_user_event = Api::V1::RoomUserEvent.new(api_v1_room_user_event_params)

    if @api_v1_room_user_event.save
      render json: @api_v1_room_user_event, status: :created, location: @api_v1_room_user_event
    else
      render json: @api_v1_room_user_event.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/room_user_events/1
  def update
    if @api_v1_room_user_event.update(api_v1_room_user_event_params)
      render json: @api_v1_room_user_event
    else
      render json: @api_v1_room_user_event.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/room_user_events/1
  def destroy
    @api_v1_room_user_event.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_api_v1_room_user_event
      @api_v1_room_user_event = Api::V1::RoomUserEvent.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def api_v1_room_user_event_params
      params.expect(api_v1_room_user_event: [ :operationRoomId, :userId, :eventType, :eventAt ])
    end
end
