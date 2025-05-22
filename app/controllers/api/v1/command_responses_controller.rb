class CommandResponsesController < ApplicationController
  before_action :set_command_response, only: %i[ show update destroy ]

  # GET /api/v1/command_responses
  def index
    @command_responses = CommandResponse.all

    render json: @command_responses
  end

  # GET /api/v1/command_responses/1
  def show
    render json: @command_response
  end

  # POST /api/v1/command_responses
  def create
    @command_response = CommandResponse.new(command_response_params)

    if @command_response.save
      render json: @command_response, status: :created, location: @command_response
    else
      render json: @command_response.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/command_responses/1
  def update
    if @command_response.update(command_response_params)
      render json: @command_response
    else
      render json: @command_response.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/command_responses/1
  def destroy
    @command_response.destroy!
    render json: { message: "Command response successfully deleted" }, status: :ok
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_command_response
      @command_response = CommandResponse.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def command_response_params
      params.expect(command_response: [ :commandId, :content, :responseType, :priority, :isActive ])
    end
end
