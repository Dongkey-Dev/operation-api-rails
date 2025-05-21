class Api::V1::CommandsController < ApplicationController
  before_action :set_api_v1_command, only: %i[ show update destroy ]

  # GET /api/v1/commands
  def index
    @api_v1_commands = Api::V1::Command.all

    render json: @api_v1_commands
  end

  # GET /api/v1/commands/1
  def show
    render json: @api_v1_command
  end

  # POST /api/v1/commands
  def create
    @api_v1_command = Api::V1::Command.new(api_v1_command_params)

    if @api_v1_command.save
      render json: @api_v1_command, status: :created, location: @api_v1_command
    else
      render json: @api_v1_command.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/commands/1
  def update
    if @api_v1_command.update(api_v1_command_params)
      render json: @api_v1_command
    else
      render json: @api_v1_command.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/commands/1
  def destroy
    @api_v1_command.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_api_v1_command
      @api_v1_command = Api::V1::Command.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def api_v1_command_params
      params.expect(api_v1_command: [ :keyword, :description, :customerId, :operationRoomId, :isActive, :createdAt, :updatedAt, :isDeleted, :deletedAt ])
    end
end
