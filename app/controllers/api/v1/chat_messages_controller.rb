class Api::V1::ChatMessagesController < Api::ApiController
  include Pagy::Backend

  before_action :authenticate_user
  # Only use set_chat_message when we implement these actions
  # before_action :set_chat_message, only: %i[ show update destroy ]

  # Configure token-based customer filtering for ChatMessage
  filter_by_token_customer ChatMessage

  # Define scopes that can be used for filtering
  has_scope :by_operation_room, as: :operation_room_id
  has_scope :by_user, as: :user_id
  has_scope :created_between

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
      @resources = @resources.where("created_at < ?", cursor_time)
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
  # def show
  #   render json: @chat_message
  # end

  # GET /api/v1/chat_messages/counts_by_period
  def counts_by_period
    # Validate parameters
    param! :start_date, String, required: true, transform: :presence
    param! :end_date, String, required: true, transform: :presence
    param! :period_unit, String, required: true, transform: :presence,
           in: ChatMessage::VALID_PERIOD_UNITS
    param! :operation_room_id, Integer, transform: :presence

    begin
      start_date = Time.zone.parse(params[:start_date])
      end_date = Time.zone.parse(params[:end_date])
    rescue ArgumentError
      return render json: {
        errors: [ {
          code: "invalid_date_format",
          detail: "Invalid date format. Use ISO 8601 format (e.g., 2025-06-11)"
        } ]
      }, status: :unprocessable_entity
    end

    # Build base query with scopes and authorize with policy_scope to ensure
    # only messages from operation rooms the current user has access to are counted
    base_query = policy_scope(apply_scopes(ChatMessage))
    
    # Apply operation_room_id filter if provided
    if params[:operation_room_id].present?
      base_query = base_query.by_operation_room(params[:operation_room_id])
    end

    # Get counts by period
    counts = base_query.count_by_period(
      params[:period_unit],
      start_date,
      end_date
    )

    # Format the response
    data = counts.map do |result|
      {
        period: result.period.strftime("%Y-%m-%d"),
        count: result.count
      }
    end

    render json: { data: data }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_chat_message
      @chat_message = ChatMessage.find(params[:id])
    end

    # Override Pundit's current_user method to use current_customer for authorization
    def pundit_user
      current_customer
    end

  # POST /api/v1/chat_messages/send_kakao_message
  # Sends a message to a Kakao chat room using the operation room's title/origin_title as the room identifier
  def send_kakao_message
    # Step 1: Validate required parameters
    param! :operation_room_id, Integer, transform: :presence
    param! :message, String, required: true, transform: :presence
    param! :room_name, String, transform: :presence

    # Step 2: Find the operation room based on provided parameters
    operation_room = nil

    if params[:room_name].present?
      # Step 2a: If room_name is provided, find the room by name and verify ownership
      operation_room = OperationRoom.where("title = ? OR origin_title = ?", params[:room_name], params[:room_name])
                                   .find_by(customer_admin_user_id: @current_user.id)

      unless operation_room
        return render json: {
          errors: [ { code: "not_found", detail: "Operation room with the provided name not found or not owned by you" } ]
        }, status: :not_found
      end
    elsif params[:operation_room_id].present?
      # Step 2b: If operation_room_id is provided, find the room by ID
      operation_room = OperationRoom.find_by(id: params[:operation_room_id])

      unless operation_room
        return render json: {
          errors: [ { code: "not_found", detail: "Operation room with ID #{params[:operation_room_id]} not found" } ]
        }, status: :not_found
      end

      # Step 2c: Verify ownership if finding by ID
      unless operation_room.customer_admin_user_id == @current_user.id
        return render json: {
          errors: [ { code: "forbidden", detail: "You don't have permission to send messages to this operation room" } ]
        }, status: :forbidden
      end
    else
      # Step 2d: Handle case when neither parameter is provided
      return render json: {
        errors: [ { code: "bad_request", detail: "Either operation_room_id or room_name must be provided" } ]
      }, status: :bad_request
    end

    # Step 3: Extract room identifier from the operation room
    room_identifier = operation_room.title.presence || operation_room.origin_title

    unless room_identifier.present?
      return render json: {
        errors: [ { code: "unprocessable_entity", detail: "The operation room has no title or origin_title" } ]
      }, status: :unprocessable_entity
    end

    # Step 4: Prepare and send the request to Kakao API
    begin
      uri = URI.parse("https://server-orcl.dongkey-me.link/api/v1/kakao/message/send")
      request = Net::HTTP::Post.new(uri)
      request.set_form_data({
        "room" => room_identifier,
        "message" => params[:message]
      })

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      response = http.request(request)

      # Step 5: Handle the API response
      if response.code.to_i >= 200 && response.code.to_i < 300
        # Success response
        render json: {
          data: {
            status: "success",
            room: room_identifier,
            message: params[:message],
            operation_room_id: operation_room.id
          }
        }, status: :ok
      else
        # Error response from Kakao API
        render json: {
          errors: [ {
            code: "external_api_error",
            detail: "Failed to send message to Kakao API: #{response.code} #{response.message}",
            response_body: response.body
          } ]
        }, status: :unprocessable_entity
      end
    rescue => e
      # Step 6: Handle any exceptions during the request
      render json: {
        errors: [ { code: "request_error", detail: "Error sending message: #{e.message}" } ]
      }, status: :internal_server_error
    end
  end
end
