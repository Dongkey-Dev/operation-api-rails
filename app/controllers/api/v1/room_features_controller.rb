class Api::V1::RoomFeaturesController < Api::ApiController
  include Pagy::Backend
  include IncludableResources

  before_action :authenticate_user
  before_action :set_room_feature, only: %i[show update destroy]

  configure_includes do |config|
    config.allowed_includes = %w[operation_room feature]
    config.default_limits = {
      operation_room: 1,
      feature: 1
    }
  end

  # GET /api/v1/room_features
  def index
    # Validate and transform parameters
    param! :operation_room_id, Integer, transform: :presence
    param! :feature_id, Integer, transform: :presence
    param! :is_active, :boolean
    param! :include, String, transform: :presence
    param! :limit, Integer, default: 25, min: 1, max: 100
    param! :page, Integer, default: 1, min: 1
    param! :sort_by, String, in: %w[created_at updated_at], default: "created_at"
    param! :sort_order, String, in: %w[asc desc], default: "desc"

    # Apply policy scope for authorization
    base_query = policy_scope(RoomFeature)

    # Apply filters
    base_query = base_query.by_operation_room(params[:operation_room_id]) if params[:operation_room_id].present?
    base_query = base_query.by_feature(params[:feature_id]) if params[:feature_id].present?
    base_query = params[:is_active] ? base_query.active : base_query.inactive if params[:is_active].present?

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

  # GET /api/v1/room_features/1
  def show
    authorize @room_feature

    # Apply includes for the single record
    with_includes_for_record(@room_feature)

    render json: { data: @room_feature }
  end

  # POST /api/v1/room_features
  def create
    # Check if a room feature with the same operation_room_id and feature_id already exists
    existing_room_feature = RoomFeature.find_by(
      operation_room_id: room_feature_params[:operation_room_id],
      feature_id: room_feature_params[:feature_id]
    )

    if existing_room_feature
      # If it exists, return the existing record
      @room_feature = existing_room_feature
      authorize @room_feature
      render json: { data: @room_feature }
    else
      # If it doesn't exist, create a new one
      @room_feature = RoomFeature.new(room_feature_params)
      authorize @room_feature

      if @room_feature.save
        render json: { data: @room_feature }, status: :created
      else
        render json: { errors: format_validation_errors(@room_feature) }, status: :unprocessable_entity
      end
    end
  end

  # PATCH/PUT /api/v1/room_features/1
  def update
    authorize @room_feature

    if @room_feature.update(room_feature_params)
      render json: { data: @room_feature }
    else
      render json: { errors: format_validation_errors(@room_feature) }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/room_features/1
  def destroy
    authorize @room_feature
    @room_feature.destroy!
    render json: { message: "Room feature successfully deleted" }, status: :ok
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_room_feature
      @room_feature = RoomFeature.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def room_feature_params
      # Transform camelCase keys to snake_case and permit allowed parameters
      params.require(:room_feature)
            .transform_keys { |key| key.to_s.underscore }
            .permit(:operation_room_id, :feature_id, :is_active)
    end
end
