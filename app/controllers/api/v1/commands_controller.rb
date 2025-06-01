class Api::V1::CommandsController < Api::ApiController
  include Pagy::Backend

  before_action :authenticate_user
  before_action :set_command, only: %i[ show update destroy ]

  # Define scopes that can be used for filtering
  has_scope :active, type: :boolean
  has_scope :inactive, type: :boolean
  has_scope :deleted, type: :boolean
  has_scope :by_customer, as: :customer_id
  has_scope :by_operation_room, as: :operation_room_id
  has_scope :search_by_keyword, as: :keyword

  # GET /api/v1/commands
  def index
    # Validate and transform parameters
    param! :active, :boolean
    param! :customer_id, Integer, transform: :presence
    param! :operation_room_id, Integer, transform: :presence
    param! :limit, Integer, default: 25, min: 1, max: 100
    param! :cursor, Integer, default: 1, min: 1
    param! :sortBy, String, in: %w[active created_at updated_at], required: false
    param! :sortOrder, String, in: %w[asc desc], default: 'asc'

    # Apply scopes and sorting with policy_scope for authorization
    pagination = pagination_params
    base_query = policy_scope(apply_scopes(Command))

    if pagination[:sort_by].present?
      base_query = base_query.order(pagination[:sort_by] => pagination[:sort_order])
    end

    # Apply Pagy pagination
    pagination = pagination_params
    @pagy, @commands = pagy(base_query, items: pagination[:items])

    # Calculate next cursor
    next_cursor = @pagy.page < @pagy.pages ? @pagy.page + 1 : nil

    # Render response with pagination metadata
    render json: {
      data: @commands,
      pagination: {
        limit: @pagy.items,
        total: @pagy.count,
        next_cursor: next_cursor
      }
    }
  end

  # GET /api/v1/commands/1
  def show
    authorize @command
    render json: { data: @command }
  end

  # POST /api/v1/commands
  def create
    @command = Command.new(command_params)
    authorize @command

    if @command.save
      render json: { data: @command }, status: :created
    else
      render json: { errors: format_errors(@command.errors) }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/commands/1
  def update
    authorize @command
    
    if @command.update(command_params)
      render json: { data: @command }
    else
      render json: { errors: format_errors(@command.errors) }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/commands/1
  def destroy
    authorize @command
    @command.destroy!
    render json: { message: "Command successfully deleted" }, status: :ok
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
    def set_command
      @command = Command.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { 
        error: {
          code: "not_found",
          message: "Command not found"
        }
      }, status: :not_found
    end

    # Only allow a list of trusted parameters through.
    def command_params
      params.require(:command).permit(:keyword, :description, :customer_id, :operation_room_id, :is_active)
    end
    
    # Format error messages
    def format_errors(errors)
      errors.map do |attribute, message|
        {
          code: error_code_for(attribute),
          detail: message,
          source: { pointer: "/data/attributes/#{attribute}" }
        }
      end
    end
    
    # Map error attributes to error codes
    def error_code_for(attribute)
      {
        keyword: "invalid_keyword",
        description: "invalid_description",
        customer_id: "invalid_customer_id",
        operation_room_id: "invalid_operation_room_id",
        is_active: "invalid_active_status"
      }[attribute.to_sym] || "validation_error"
    end
    
    # Override Pundit's current_user method to use our @current_user
    def pundit_user
      @current_user
    end
    
    # Pagination parameters
    def pagination_params
      {
        items: params[:limit] || 25,
        page: params[:cursor] || 1,
        sort_by: params[:sortBy],
        sort_order: params[:sortOrder]&.to_sym || :asc
      }
    end
end
