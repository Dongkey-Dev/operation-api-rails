class Api::V1::FeaturesController < ApplicationController
  before_action :set_api_v1_feature, only: %i[ show update destroy ]

  # GET /api/v1/features
  def index
    @api_v1_features = Api::V1::Feature.all

    render json: @api_v1_features
  end

  # GET /api/v1/features/1
  def show
    render json: @api_v1_feature
  end

  # POST /api/v1/features
  def create
    @api_v1_feature = Api::V1::Feature.new(api_v1_feature_params)

    if @api_v1_feature.save
      render json: @api_v1_feature, status: :created, location: @api_v1_feature
    else
      render json: @api_v1_feature.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/features/1
  def update
    if @api_v1_feature.update(api_v1_feature_params)
      render json: @api_v1_feature
    else
      render json: @api_v1_feature.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/features/1
  def destroy
    @api_v1_feature.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_api_v1_feature
      @api_v1_feature = Api::V1::Feature.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def api_v1_feature_params
      params.expect(api_v1_feature: [ :name, :description, :createdAt, :updatedAt ])
    end
end
