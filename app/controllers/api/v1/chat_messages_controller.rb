class Api::V1::ChatMessagesController < Api::ApiController
  include Pagy::Backend

  before_action :authenticate_user
  before_action :set_chat_message, only: %i[ show ]
  
  # Configure token-based customer filtering for ChatMessage
  filter_by_token_customer ChatMessage

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
    # Token-based customer filtering is automatically applied by the TokenCustomerFiltering concern
    base_query = apply_scopes(ChatMessage)
    
    @resources = base_query.order(created_at: :desc)
    
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
    
    # Override Pundit's current_user method to use our @current_user
    def pundit_user
      @current_user
    end
end
