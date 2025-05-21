class Api::V1::CommandResponsesController < ApplicationController
  before_action :set_api_v1_command_response, only: %i[ show update destroy ]

  # GET /api/v1/command_responses
  def index
    @api_v1_command_responses = Api::V1::CommandResponse.all

    render json: @api_v1_command_responses
  end

  # GET /api/v1/command_responses/1
  def show
    render json: @api_v1_command_response
  end

  # POST /api/v1/command_responses
  def create
    @api_v1_command_response = Api::V1::CommandResponse.new(api_v1_command_response_params)

    if @api_v1_command_response.save
      render json: @api_v1_command_response, status: :created, location: @api_v1_command_response
    else
      render json: @api_v1_command_response.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/command_responses/1
  def update
    if @api_v1_command_response.update(api_v1_command_response_params)
      render json: @api_v1_command_response
    else
      render json: @api_v1_command_response.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/command_responses/1
  def destroy
    @api_v1_command_response.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_api_v1_command_response
      @api_v1_command_response = Api::V1::CommandResponse.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def api_v1_command_response_params
      params.expect(api_v1_command_response: [ :commandId, :content, :responseType, :priority, :isActive, :createdAt, :updatedAt, :isDeleted, :deletedAt ])
    end
end
