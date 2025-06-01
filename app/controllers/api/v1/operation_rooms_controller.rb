class Api::V1::OperationRoomsController < Api::ApiController
  include Pagy::Backend

  before_action :authenticate_user
  before_action :set_operation_room, only: %i[ show update destroy ]

  # Define scopes that can be used for filtering
  has_scope :by_platform
  has_scope :by_room_type
  has_scope :by_customer_admin
  has_scope :by_admin_room
  has_scope :search_by_title
  has_scope :with_due_date_approaching
  has_scope :ordered_by_created
  has_scope :ordered_by_updated
  has_scope :ordered_by_payment

  # GET /api/v1/operation_rooms
  def index
    # Build base query with scopes and authorize with policy_scope
    base_query = policy_scope(apply_scopes(OperationRoom))

    # Apply sorting if specified
    if params[:sortBy].present?
      sort_by = params[:sortBy]
      sort_order = params[:sortOrder]&.downcase == "desc" ? :desc : :asc
      base_query = base_query.order(sort_by => sort_order)
    else
      # Default sorting
      base_query = base_query.order(created_at: :desc)
    end

    # Apply Pagy pagination
    items_per_page = params[:limit].present? ? params[:limit].to_i : 15
    page_number = params[:page].present? ? params[:page].to_i : 1

    begin
      @pagy, @operation_rooms = pagy(base_query, items: items_per_page, page: page_number)

      # Determine if there's a next page
      has_next_page = @pagy.page < @pagy.pages
      next_page = has_next_page ? @pagy.page + 1 : nil

      # Render response with pagination metadata following our API standards
      render json: {
        data: @operation_rooms,
        meta: {
          pagination: {
            per_page: items_per_page,
            current_page: @pagy.page,
            total_pages: @pagy.pages,
            total_count: @pagy.count,
            next_page: next_page
          }
        }
      }
    rescue Pagy::OverflowError
      # Handle the case where page is out of bounds
      render json: {
        data: [],
        meta: {
          pagination: {
            per_page: items_per_page,
            current_page: page_number,
            total_pages: 0,
            total_count: 0,
            next_page: nil
          }
        }
      }
    end
  end

  # GET /api/v1/operation_rooms/1
  def show
    authorize @operation_room
    render json: @operation_room
  end

  # POST /api/v1/operation_rooms
  def create
    @operation_room = OperationRoom.new(operation_room_params)
    authorize @operation_room

    if @operation_room.save
      render json: @operation_room, status: :created, location: @operation_room
    else
      render json: @operation_room.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/operation_rooms/1
  def update
    authorize @operation_room
    
    if @operation_room.update(operation_room_params)
      render json: @operation_room
    else
      render json: @operation_room.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/operation_rooms/1
  def destroy
    authorize @operation_room
    @operation_room.destroy!
    head :no_content
  end

  private
    # Authenticate user from token
    def authenticate_user
      # For now, we'll use a simple token-based authentication
      # In a real application, you would use JWT or another authentication method
      token = request.headers['Authorization']&.split(' ')&.last
      @current_user = Customer.find_by(token: token)
      
      unless @current_user
        render json: {
          error: {
            code: "unauthorized",
            message: "You need to sign in or sign up before continuing."
          }
        }, status: :unauthorized
      end
    end
  
    # Use callbacks to share common setup or constraints between actions.
    def set_operation_room
      @operation_room = OperationRoom.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: {
        error: {
          code: "not_found",
          message: "Operation room not found"
        }
      }, status: :not_found
    end

    # Only allow a list of trusted parameters through.
    def operation_room_params
      params.require(:operation_room).permit(
        :chatRoomId, :openChatLink, :originTitle, :title, :accumulatedPaymentAmount,
        :platformType, :roomType, :customerAdminRoomId, :customerAdminUserId,
        :dueDate, :createdAt, :updatedAt
      )
    end
    
    # Override Pundit's current_user method to use our @current_user
    def pundit_user
      @current_user
    end
end
