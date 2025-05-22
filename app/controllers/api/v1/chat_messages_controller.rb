class Api::V1::ChatMessagesController < ApplicationController
  before_action :set_chat_message, only: %i[ show update destroy ]

  # Define scopes that can be used for filtering
  has_scope :created_between
  has_scope :by_operation_room
  has_scope :by_user
  has_scope :latest
  has_scope :oldest

  # GET /api/v1/chat_messages
  def index
    # Validate scope parameters
    param! :operation_room_id, Integer, transform: :presence
    param! :user_id, Integer, transform: :presence
    param! :created_between, Array do |p|
      p.param! :start_date, DateTime
      p.param! :end_date, DateTime
    end

    # Get pagination params and build base query
    pagination = pagination_params
    base_query = apply_scopes(ChatMessage)

    if pagination[:sort_by].present?
      base_query = base_query.order(pagination[:sort_by] => pagination[:sort_order])
    end

    # Apply Pagy pagination
    pagination = pagination_params
    @pagy, @chat_messages = pagy(base_query, items: pagination[:items])

    # Calculate next cursor
    next_cursor = @pagy.page < @pagy.pages ? @pagy.page + 1 : nil

    # Render response with pagination metadata
    render json: {
      data: @chat_messages,
      pagination: {
        limit: @pagy.items,
        total: @pagy.count,
        next_cursor: next_cursor
      }
    }
  end

  # GET /api/v1/chat_messages/1
  def show
    render json: @chat_message
  end

  # POST /api/v1/chat_messages
  def create
    @chat_message = ChatMessage.new(chat_message_params)

    if @chat_message.save
      render json: @chat_message, status: :created, location: @chat_message
    else
      render json: @chat_message.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/chat_messages/1
  def update
    if @chat_message.update(chat_message_params)
      render json: @chat_message
    else
      render json: @chat_message.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/chat_messages/1
  def destroy
    @chat_message.destroy!
    render json: { message: "Chat message successfully deleted" }, status: :ok
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_chat_message
      @chat_message = ChatMessage.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def chat_message_params
      params.expect(chat_message: [ :operationRoomId, :userId, :content ])
    end
end
