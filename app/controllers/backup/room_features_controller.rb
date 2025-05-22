class Api::V1::RoomFeaturesController < ApplicationController
  before_action :set_api_v1_room_feature, only: %i[ show update destroy ]

  # GET /api/v1/room_features
  def index
    @api_v1_room_features = Api::V1::RoomFeature.all

    render json: @api_v1_room_features
  end

  # GET /api/v1/room_features/1
  def show
    render json: @api_v1_room_feature
  end

  # POST /api/v1/room_features
  def create
    @api_v1_room_feature = Api::V1::RoomFeature.new(api_v1_room_feature_params)

    if @api_v1_room_feature.save
      render json: @api_v1_room_feature, status: :created, location: @api_v1_room_feature
    else
      render json: @api_v1_room_feature.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/room_features/1
  def update
    if @api_v1_room_feature.update(api_v1_room_feature_params)
      render json: @api_v1_room_feature
    else
      render json: @api_v1_room_feature.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/room_features/1
  def destroy
    @api_v1_room_feature.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_api_v1_room_feature
      @api_v1_room_feature = Api::V1::RoomFeature.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def api_v1_room_feature_params
      params.expect(api_v1_room_feature: [ :operationRoomId, :featureId, :isActive, :createdAt, :updatedAt ])
    end
end
