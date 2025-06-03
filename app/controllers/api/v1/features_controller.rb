class Api::V1::FeaturesController < Api::ApiController
  include Pagy::Backend
  include IncludableResources
  
  before_action :authenticate_user
  before_action :set_feature, only: %i[show update destroy]
  
  configure_includes do |config|
    config.allowed_includes = %w[operation_rooms room_features]
    config.default_limits = {
      operation_rooms: 10,
      room_features: 10
    }
  end

  # GET /api/v1/features
  def index
    # Validate and transform parameters
    param! :name, String, transform: :presence
    param! :category, String, transform: :presence
    param! :include, String, transform: :presence
    param! :limit, Integer, default: 25, min: 1, max: 100
    param! :page, Integer, default: 1, min: 1
    param! :sort_by, String, in: %w[name category created_at updated_at], default: "name"
    param! :sort_order, String, in: %w[asc desc], default: "asc"

    # Apply policy scope for authorization
    base_query = policy_scope(Feature)
    
    # Apply filters
    base_query = base_query.search_by_name(params[:name]) if params[:name].present?
    base_query = base_query.where(category: params[:category]) if params[:category].present?
    
    # Apply sorting
    base_query = base_query.order(params[:sort_by] => params[:sort_order])
    
    # Apply pagination and includes
    result = with_includes_and_pagination(base_query,
                                       items_per_page: params[:limit],
                                       page_number: params[:page])
  
    # Prepare records with includes for JSON serialization
    serialized_records = if result[:include_options].present?
      result[:records].as_json(include: result[:include_options])
    else
      result[:records].as_json
    end
  
    # Render response with pagination metadata
    render json: {
      data: serialized_records,
      meta: {
        pagination: result[:pagination]
      }
    }
  end

  # GET /api/v1/features/1
  def show
    authorize @feature
    
    # Apply includes for the single record
    result = with_includes_for_record(@feature)
    
    # Prepare record with includes for JSON serialization
    serialized_record = if result[:include_options].present?
      @feature.as_json(include: result[:include_options])
    else
      @feature.as_json
    end
    
    render json: { data: serialized_record }
  end

  # POST /api/v1/features
  def create
    @feature = Feature.new(feature_params)
    authorize @feature

    if @feature.save
      render json: { data: @feature }, status: :created
    else
      render json: { errors: format_validation_errors(@feature) }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/features/1
  def update
    authorize @feature
    
    if @feature.update(feature_params)
      render json: { data: @feature }
    else
      render json: { errors: format_validation_errors(@feature) }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/features/1
  def destroy
    authorize @feature
    @feature.destroy!
    render json: { message: "Feature successfully deleted" }, status: :ok
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_feature
      @feature = Feature.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def feature_params
      params.require(:feature).permit(:name, :description, :category)
    end
end
