class Api::V1::CommandsController < Api::ApiController
  include Pagy::Backend
  include IncludableResources

  before_action :authenticate_user
  before_action :set_command, only: %i[show update destroy toggle_active]

  # Define scopes that can be used for filtering
  has_scope :active, type: :boolean
  has_scope :inactive, type: :boolean
  has_scope :deleted, type: :boolean
  has_scope :by_customer, as: :customer_id
  has_scope :by_operation_room, as: :operation_room_id
  has_scope :search_by_keyword, as: :keyword

  # Configure includable resources
  configure_includes do |config|
    config.allowed_includes = %w[customer operation_room command_responses]
    config.default_limits = {
      customer: 1,
      operation_room: 1,
      command_responses: 10
    }
  end

  # GET /api/v1/commands
  def index
    # Validate and transform parameters
    param! :active, :boolean
    param! :customer_id, Integer, transform: :presence
    param! :operation_room_id, Integer, transform: :presence
    param! :keyword, String, transform: :presence
    param! :include, String, transform: :presence
    param! :limit, Integer, default: 25, min: 1, max: 100
    param! :page, Integer, default: 1, min: 1
    param! :sort_by, String, in: %w[keyword created_at updated_at], default: 'created_at'
    param! :sort_order, String, in: %w[asc desc], default: 'desc'

    # Apply scopes with policy_scope for authorization
    base_query = policy_scope(apply_scopes(Command))

    # Apply sorting
    base_query = base_query.order(params[:sort_by] => params[:sort_order])

    # Apply pagination and includes
    result = with_includes_and_pagination(base_query, 
                                         items_per_page: params[:limit], 
                                         page_number: params[:page])

    # Render response with pagination metadata
    render json: {
      data: result[:records],
      meta: {
        pagination: result[:pagination]
      }
    }
  end

  # GET /api/v1/commands/active
  def active
    param! :customer_id, Integer, transform: :presence
    param! :operation_room_id, Integer, transform: :presence
    param! :keyword, String, transform: :presence
    param! :include, String, transform: :presence
    param! :limit, Integer, default: 25, min: 1, max: 100
    param! :page, Integer, default: 1, min: 1
    param! :sort_by, String, in: %w[keyword created_at updated_at], default: 'created_at'
    param! :sort_order, String, in: %w[asc desc], default: 'desc'

    # Apply scopes with active filter
    base_query = policy_scope(apply_scopes(Command.active))

    # Apply sorting
    base_query = base_query.order(params[:sort_by] => params[:sort_order])

    # Apply pagination and includes
    @pagy, @commands = with_includes_and_pagination(base_query)

    # Render response with pagination metadata
    render json: {
      data: @commands,
      meta: {
        pagination: pagy_metadata(@pagy)
      }
    }
  end

  # GET /api/v1/commands/customer/:id
  def by_customer
    param! :id, Integer, required: true
    param! :active, :boolean
    param! :keyword, String, transform: :presence
    param! :include, String, transform: :presence
    param! :limit, Integer, default: 25, min: 1, max: 100
    param! :page, Integer, default: 1, min: 1
    param! :sort_by, String, in: %w[keyword created_at updated_at], default: 'created_at'
    param! :sort_order, String, in: %w[asc desc], default: 'desc'

    # Find the customer first to ensure it exists and user has access
    customer = Customer.find(params[:id])
    authorize customer, :show?

    # Apply scopes with customer filter
    base_query = policy_scope(apply_scopes(Command.by_customer(params[:id])))
    
    # Apply active filter if specified
    base_query = base_query.active if params[:active]

    # Apply sorting
    base_query = base_query.order(params[:sort_by] => params[:sort_order])

    # Apply pagination and includes
    @pagy, @commands = with_includes_and_pagination(base_query)

    # Render response with pagination metadata
    render json: {
      data: @commands,
      meta: {
        pagination: pagy_metadata(@pagy)
      }
    }
  end

  # GET /api/v1/commands/active/customer/:id
  def active_by_customer
    param! :id, Integer, required: true
    param! :keyword, String, transform: :presence
    param! :include, String, transform: :presence
    param! :limit, Integer, default: 25, min: 1, max: 100
    param! :page, Integer, default: 1, min: 1
    param! :sort_by, String, in: %w[keyword created_at updated_at], default: 'created_at'
    param! :sort_order, String, in: %w[asc desc], default: 'desc'

    # Find the customer first to ensure it exists and user has access
    customer = Customer.find(params[:id])
    authorize customer, :show?

    # Apply scopes with customer filter and active filter
    base_query = policy_scope(apply_scopes(Command.active.by_customer(params[:id])))

    # Apply sorting
    base_query = base_query.order(params[:sort_by] => params[:sort_order])

    # Apply pagination and includes
    @pagy, @commands = with_includes_and_pagination(base_query)

    # Render response with pagination metadata
    render json: {
      data: @commands,
      meta: {
        pagination: pagy_metadata(@pagy)
      }
    }
  end

  # GET /api/v1/commands/room/:id
  def by_operation_room
    param! :id, Integer, required: true
    param! :active, :boolean
    param! :keyword, String, transform: :presence
    param! :include, String, transform: :presence
    param! :limit, Integer, default: 25, min: 1, max: 100
    param! :page, Integer, default: 1, min: 1
    param! :sort_by, String, in: %w[keyword created_at updated_at], default: 'created_at'
    param! :sort_order, String, in: %w[asc desc], default: 'desc'

    # Find the operation room first to ensure it exists and user has access
    operation_room = OperationRoom.find(params[:id])
    authorize operation_room, :show?

    # Apply scopes with operation room filter
    base_query = policy_scope(apply_scopes(Command.by_operation_room(params[:id])))
    
    # Apply active filter if specified
    base_query = base_query.active if params[:active]

    # Apply sorting
    base_query = base_query.order(params[:sort_by] => params[:sort_order])

    # Apply pagination and includes
    @pagy, @commands = with_includes_and_pagination(base_query)

    # Render response with pagination metadata
    render json: {
      data: @commands,
      meta: {
        pagination: pagy_metadata(@pagy)
      }
    }
  end

  # GET /api/v1/commands/active/room/:id
  def active_by_operation_room
    param! :id, Integer, required: true
    param! :keyword, String, transform: :presence
    param! :include, String, transform: :presence
    param! :limit, Integer, default: 25, min: 1, max: 100
    param! :page, Integer, default: 1, min: 1
    param! :sort_by, String, in: %w[keyword created_at updated_at], default: 'created_at'
    param! :sort_order, String, in: %w[asc desc], default: 'desc'

    # Find the operation room first to ensure it exists and user has access
    operation_room = OperationRoom.find(params[:id])
    authorize operation_room, :show?

    # Apply scopes with operation room filter and active filter
    base_query = policy_scope(apply_scopes(Command.active.by_operation_room(params[:id])))

    # Apply sorting
    base_query = base_query.order(params[:sort_by] => params[:sort_order])

    # Apply pagination and includes
    @pagy, @commands = with_includes_and_pagination(base_query)

    # Render response with pagination metadata
    render json: {
      data: @commands,
      meta: {
        pagination: pagy_metadata(@pagy)
      }
    }
  end

  # GET /api/v1/commands/1
  def show
    authorize @command
    with_includes_for_record(@command)
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

  # PUT /api/v1/commands/1/toggle_active
  def toggle_active
    authorize @command
    
    new_status = !@command.is_active
    if @command.update(is_active: new_status)
      render json: { 
        data: @command,
        message: "Command is now #{new_status ? 'active' : 'inactive'}"
      }
    else
      render json: { errors: format_errors(@command.errors) }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/commands/1
  def destroy
    authorize @command
    @command.update(is_deleted: true, deleted_at: Time.current)
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
          errors: [{
            code: "unauthorized",
            detail: "You need to sign in or sign up before continuing."
          }]
        }, status: :unauthorized
      end
    end
  
    # Use callbacks to share common setup or constraints between actions.
    def set_command
      @command = Command.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { 
        errors: [{
          code: "not_found",
          detail: "Command not found"
        }]
      }, status: :not_found
    end

    # Only allow a list of trusted parameters through.
    def command_params
      params.require(:command).permit(
        :keyword, 
        :description, 
        :customer_id, 
        :operation_room_id, 
        :is_active
      )
    end
    
    # Format error messages
    def format_errors(errors)
      errors.map do |error|
        attribute = error.attribute
        message = error.message
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
        is_active: "invalid_active_status",
        base: "validation_error"
      }[attribute.to_sym] || "validation_error"
    end
    
    # Override Pundit's current_user method to use our @current_user
    def pundit_user
      @current_user
    end
end
