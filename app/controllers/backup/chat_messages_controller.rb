class ChatMessagesController < ApplicationController
  before_action :set_api_v1_chat_message, only: %i[ show update destroy ]

  # GET /api/v1/chat_messages
  def index
    @api_v1_chat_messages = ChatMessage.all

    render json: @api_v1_chat_messages
  end

  # GET /api/v1/chat_messages/1
  def show
    render json: @api_v1_chat_message
  end

  # POST /api/v1/chat_messages
  def create
    @api_v1_chat_message = ChatMessage.new(api_v1_chat_message_params)

    if @api_v1_chat_message.save
      render json: @api_v1_chat_message, status: :created, location: @api_v1_chat_message
    else
      render json: @api_v1_chat_message.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/chat_messages/1
  def update
    if @api_v1_chat_message.update(api_v1_chat_message_params)
      render json: @api_v1_chat_message
    else
      render json: @api_v1_chat_message.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/chat_messages/1
  def destroy
    @api_v1_chat_message.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_api_v1_chat_message
      @api_v1_chat_message = ChatMessage.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def api_v1_chat_message_params
      params.expect(api_v1_chat_message: [ :_id, :operationRoomId, :userId, :content, :createdAt ])
    end
end
