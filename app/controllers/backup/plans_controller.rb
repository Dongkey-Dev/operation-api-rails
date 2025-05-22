class Api::V1::PlansController < ApplicationController
  before_action :set_api_v1_plan, only: %i[ show update destroy ]

  # GET /api/v1/plans
  def index
    @api_v1_plans = Api::V1::Plan.all

    render json: @api_v1_plans
  end

  # GET /api/v1/plans/1
  def show
    render json: @api_v1_plan
  end

  # POST /api/v1/plans
  def create
    @api_v1_plan = Api::V1::Plan.new(api_v1_plan_params)

    if @api_v1_plan.save
      render json: @api_v1_plan, status: :created, location: @api_v1_plan
    else
      render json: @api_v1_plan.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/plans/1
  def update
    if @api_v1_plan.update(api_v1_plan_params)
      render json: @api_v1_plan
    else
      render json: @api_v1_plan.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/plans/1
  def destroy
    @api_v1_plan.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_api_v1_plan
      @api_v1_plan = Api::V1::Plan.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def api_v1_plan_params
      params.expect(api_v1_plan: [ :name, :description, :price, :features, :createdAt, :updatedAt ])
    end
end
