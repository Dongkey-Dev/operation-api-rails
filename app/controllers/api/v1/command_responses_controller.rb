class Api::V1::CommandResponsesController < Api::ApiController
  include Pagy::Backend
  include IncludableResources

  before_action :authenticate_user
  before_action :set_command_response, only: %i[show update destroy]
  
  # Configure token-based customer filtering for CommandResponse
  filter_by_token_customer CommandResponse

  # Define scopes that can be used for filtering
  has_scope :active, type: :boolean
  has_scope :inactive, type: :boolean
  has_scope :deleted, type: :boolean
  has_scope :by_command, as: :command_id
  has_scope :by_type, as: :response_type
  has_scope :by_priority, as: :priority
  
  # Configure includable resources
  configure_includes do |config|
    config.allowed_includes = %w[command]
    config.default_limits = {
      command: 1
    }
  end

  # GET /api/v1/command_responses
  def index
    # Validate and transform parameters
    param! :active, :boolean
    param! :is_active, :boolean
    param! :command_id, Integer, transform: :presence
    param! :response_type, String, transform: :presence
    param! :priority, Integer, transform: :presence
    param! :include, String, transform: :presence
    param! :limit, Integer, default: 25, min: 1, max: 100
    param! :page, Integer, default: 1, min: 1
    param! :sort_by, String, in: %w[priority created_at updated_at], default: 'priority'
    param! :sort_order, String, in: %w[asc desc], default: 'desc'

    # Apply scopes with policy_scope for authorization
    # Token-based customer filtering is automatically applied by the TokenCustomerFiltering concern
    base_query = policy_scope(apply_scopes(CommandResponse))

    # Apply active filter if specified (for backward compatibility)
    base_query = base_query.active if params[:active].present?
    
    # Apply is_active filter if specified
    base_query = base_query.where(is_active: params[:is_active]) if params[:is_active].present?

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

  # GET /api/v1/command_responses/active
# This method is kept for backward compatibility
# New requests should use GET /api/v1/command_responses?active=true
  def active
    redirect_to api_v1_command_responses_path(active: true, command_id: params[:command_id]), status: :moved_permanently
  end

  # GET /api/v1/command_responses/by_command/:id
# This method is kept for backward compatibility
# New requests should use GET /api/v1/command_responses?command_id=:id
  def by_command
    param! :id, Integer, required: true
    redirect_to api_v1_command_responses_path(command_id: params[:id], active: params[:active]), status: :moved_permanently
  end

  # GET /api/v1/command_responses/active/by_command/:id
# This method is kept for backward compatibility
# New requests should use GET /api/v1/command_responses?command_id=:id&active=true
  def active_by_command
    param! :id, Integer, required: true
    redirect_to api_v1_command_responses_path(command_id: params[:id], active: true), status: :moved_permanently
  end

  # GET /api/v1/command_responses/1
  def show
    authorize @command_response
    with_includes_for_record(@command_response)
    render json: { data: @command_response }
  end

  # POST /api/v1/command_responses
  def create
    @command_response = CommandResponse.new(command_response_params)
    
    # Ensure the command belongs to the current customer
    if current_customer.present? && @command_response.command_id.present?
      command = Command.by_token_customer(current_customer).find_by(id: @command_response.command_id)
      
      if command.nil?
        return render json: { 
          errors: [{
            code: "invalid_command",
            detail: "The specified command does not exist or you don't have permission to access it"
          }]
        }, status: :unprocessable_entity
      end
    end
    
    authorize @command_response

    if @command_response.save
      render json: { data: @command_response }, status: :created
    else
      render json: { errors: format_errors(@command_response.errors) }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/command_responses/1
  def update
    authorize @command_response
    
    # Check if this is a toggle_active request
    if params[:command_response].key?(:toggle_active) && params[:command_response][:toggle_active].present?
      # Toggle the active status
      new_status = !@command_response.is_active
      params[:command_response][:is_active] = new_status
      toggle_message = "Command response is now #{new_status ? 'active' : 'inactive'}"
    end
    
    if @command_response.update(command_response_params)
      response = { data: @command_response }
      response[:message] = toggle_message if toggle_message.present?
      render json: response
    else
      render json: { errors: format_errors(@command_response.errors) }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/command_responses/1
  def destroy
    authorize @command_response
    @command_response.update(is_deleted: true, deleted_at: Time.current)
    render json: { message: "Command response successfully deleted" }, status: :ok
  end

  private
    # Authenticate user from token - using Authentication module
    def authenticate_user
      @current_user = current_customer
      
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
    def set_command_response
      @command_response = CommandResponse.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { 
        errors: [{
          code: "not_found",
          detail: "Command response not found"
        }]
      }, status: :not_found
    end

    # Only allow a list of trusted parameters through.
    def command_response_params
      params.require(:command_response).permit(
        :command_id, 
        :content, 
        :response_type, 
        :priority, 
        :is_active,
        :toggle_active
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
        command_id: "invalid_command_id",
        content: "invalid_content",
        response_type: "invalid_response_type",
        priority: "invalid_priority",
        is_active: "invalid_active_status",
        base: "validation_error"
      }[attribute.to_sym] || "validation_error"
    end
    
    # Override Pundit's current_user method to use our @current_user
    def pundit_user
      @current_user
    end
end
