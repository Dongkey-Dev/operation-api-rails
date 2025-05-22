class Api::V1::RoomFeaturesController < ApplicationController
  before_action :set_room_feature, only: %i[ show update destroy ]

  # GET /api/v1/room_features
  def index
    @room_features = RoomFeature.all

    render json: @room_features
  end

  # GET /api/v1/room_features/1
  def show
    render json: @room_feature
  end

  # POST /api/v1/room_features
  def create
    @room_feature = RoomFeature.new(room_feature_params)

    if @room_feature.save
      render json: @room_feature, status: :created, location: @room_feature
    else
      render json: @room_feature.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/room_features/1
  def update
    if @room_feature.update(room_feature_params)
      render json: @room_feature
    else
      render json: @room_feature.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/room_features/1
  def destroy
    @room_feature.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_room_feature
      @room_feature = RoomFeature.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def  room_feature_params
      params.expect(room_feature: [ :operationRoomId, :featureId, :isActive, :createdAt, :updatedAt ])
    end
end
