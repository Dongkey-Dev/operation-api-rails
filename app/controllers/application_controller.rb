class ApplicationController < ActionController::API
  # Add has_scope for filtering resources
  include HasScope

  # Add common controller functionality here
  rescue_from StandardError, with: :render_error
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private

  def render_error(exception)
    render json: { error: exception.message }, status: :internal_server_error
  end

  def record_not_found(exception)
    render json: { error: exception.message }, status: :not_found
  end

  def pagination_params
    {
      limit: params[:limit].present? ? params[:limit].to_i : 10,
      cursor: params[:cursor].present? ? params[:cursor].to_i : nil,
      sort_by: params[:sortBy].present? ? params[:sortBy].underscore : 'created_at',
      sort_order: params[:sortOrder].present? ? params[:sortOrder].downcase : 'desc'
    }
  end

  def include_params
    params[:include].present? ? params[:include].split(',') : []
  end
end
