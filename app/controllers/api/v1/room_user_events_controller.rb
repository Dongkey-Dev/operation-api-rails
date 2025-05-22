class Api::V1::RoomUserEventsController < ApplicationController
  before_action :set_room_user_event, only: %i[ show update destroy ]

  # GET /api/v1/room_user_events
  def index
    @room_user_events = RoomUserEvent.all

    render json: @room_user_events
  end

  # GET /api/v1/room_user_events/1
  def show
    render json: @room_user_event
  end

  # POST /api/v1/room_user_events
  def create
    @room_user_event = RoomUserEvent.new(room_user_event_params)

    if @room_user_event.save
      render json: @room_user_event, status: :created, location: @room_user_event
    else
      render json: @room_user_event.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/room_user_events/1
  def update
    if @room_user_event.update(room_user_event_params)
      render json: @room_user_event
    else
      render json: @room_user_event.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/room_user_events/1
  def destroy
    @room_user_event.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_room_user_event
      @room_user_event = RoomUserEvent.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def  room_user_event_params
      params.expect(room_user_event: [ :operationRoomId, :userId, :eventType, :eventAt ])
    end
end
