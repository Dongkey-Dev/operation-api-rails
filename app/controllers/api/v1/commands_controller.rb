class Api::V1::CommandsController < ApplicationController
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

    # Apply scopes and sorting
    pagination = pagination_params
    base_query = apply_scopes(Command)

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
    render json: { data: @command }
  end

  # POST /api/v1/commands
  def create
    @command = Command.new(command_params)

    if @command.save
      render json: { data: @command }, status: :created
    else
      render json: { errors: @command.errors }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/commands/1
  def update
    if @command.update(command_params)
      render json: { data: @command }
    else
      render json: { errors: @command.errors }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/commands/1
  def destroy
    @command.destroy!
    render json: { message: "Command successfully deleted" }, status: :ok
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_command
      @command = Command.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Command not found" }, status: :not_found
    end

    # Only allow a list of trusted parameters through.
    def command_params
      params.require(:command).permit(:keyword, :description, :customer_id, :operation_room_id, :is_active)
    end
end
