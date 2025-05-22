class CommandsController < ApplicationController
  before_action :set_api_v1_command, only: %i[ show update destroy ]

  # Define scopes that can be used for filtering
  has_scope :active, type: :boolean
  has_scope :inactive, type: :boolean
  has_scope :deleted, type: :boolean
  has_scope :by_customer, as: :customer_id
  has_scope :by_operation_room, as: :operation_room_id
  has_scope :search_by_keyword, as: :keyword

  # GET /api/v1/commands
  def index
    pagination = pagination_params
    
    # Apply scopes from has_scope
    @commands = apply_scopes(Command).all
    
    # Apply sorting
    if pagination[:sort_by].present?
      @commands = @commands.order(pagination[:sort_by] => pagination[:sort_order])
    end
    
    # Apply cursor-based pagination
    if pagination[:cursor].present?
      @commands = @commands.where('id > ?', pagination[:cursor])
    end
    
    # Apply limit
    if pagination[:limit].present?
      @commands = @commands.limit(pagination[:limit])
    end
    
    response = {
      data: @commands,
      meta: {
        total: apply_scopes(Command).count,
        cursor: @commands.last&.id,
        limit: pagination[:limit]
      }
    }
    
    render json: response
  end

  # GET /api/v1/commands/1
  def show
    render json: { data: @api_v1_command }
  end

  # POST /api/v1/commands
  def create
    @command = Command.new(api_v1_command_params)

    if @command.save
      render json: { data: @command }, status: :created
    else
      render json: { errors: @command.errors }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/commands/1
  def update
    if @api_v1_command.update(api_v1_command_params)
      render json: { data: @api_v1_command }
    else
      render json: { errors: @api_v1_command.errors }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/commands/1
  def destroy
    @api_v1_command.destroy!
    render json: { message: 'Command successfully deleted' }, status: :ok
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_api_v1_command
      @api_v1_command = Command.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'Command not found' }, status: :not_found
    end

    # Only allow a list of trusted parameters through.
    def api_v1_command_params
      params.require(:command).permit(:keyword, :description, :customer_id, :operation_room_id, :is_active, :created_at, :updated_at, :is_deleted, :deleted_at)
    end
end
