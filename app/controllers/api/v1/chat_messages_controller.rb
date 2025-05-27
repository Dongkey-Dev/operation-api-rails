class Api::V1::ChatMessagesController < ApplicationController
  before_action :set_chat_message, only: %i[ show ]

  # Define scopes that can be used for filtering
  has_scope :by_operation_room, as: :operation_room_id
  has_scope :by_user, as: :user_id

  # GET /api/v1/chat_messages
  def index
    # Validate parameters
    param! :operation_room_id, Integer, transform: :presence
    param! :user_id, Integer, transform: :presence
    param! :limit, Integer, default: 20, transform: :presence
    param! :cursor, String, transform: :presence

    # Build base query
    @resources = apply_scopes(ChatMessage).order(created_at: :desc)
    
    # Apply cursor-based pagination
    if params[:cursor].present?
      cursor_time = Time.zone.parse(params[:cursor])
      @resources = @resources.where('created_at < ?', cursor_time)
    end
    
    # Apply limit
    @resources = @resources.limit(params[:limit])
    total_count = @resources.except(:limit, :offset).count
    next_cursor = @resources.last&.created_at&.iso8601

    # Render response
    render json: {
      data: @resources,
      pagination: {
        per_page: params[:limit],
        total_count: total_count,
        next_cursor: next_cursor
      }
    }
  end

  # GET /api/v1/chat_messages/1
  def show
    render json: @chat_message
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_chat_message
      @chat_message = ChatMessage.find(params[:id])
    end
end
