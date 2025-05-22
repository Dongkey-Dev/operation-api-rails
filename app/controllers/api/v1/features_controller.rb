class Api::V1::FeaturesController < ApplicationController
  before_action :set_feature, only: %i[ show update destroy ]

  # GET /api/v1/features
  def index
    @features = Feature.all

    render json: @features
  end

  # GET /api/v1/features/1
  def show
    render json: @feature
  end

  # POST /api/v1/features
  def create
    @feature = Feature.new(feature_params)

    if @feature.save
      render json: @feature, status: :created, location: @feature
    else
      render json: @feature.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/features/1
  def update
    if @feature.update(feature_params)
      render json: @feature
    else
      render json: @feature.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/features/1
  def destroy
    @feature.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_feature
      @feature = Feature.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def feature_params
      params.expect(feature: [ :name, :description, :createdAt, :updatedAt ])
    end
end
