class ApplicationController < ActionController::API
  # Add has_scope for filtering resources
  include HasScope
  # Add Pagy for pagination
  include Pagy::Backend
  # Add RailsParam for parameter validation
  include RailsParam
  # Add Pundit for authorization
  include Pundit::Authorization

  # Configure Pagy
  Pagy::DEFAULT.merge!(
    items: 20,
    outset: 0,
    overflow: :last_page,
    metadata: [:page, :items, :pages, :count, :prev, :next]
  )

  # Configure has_scope
  class << self
    def has_scope(*scopes)
      options = scopes.extract_options!
      options[:allow_blank] = true unless options.key?(:allow_blank)
      super(*scopes, options)
    end
  end

  # Error handling for API responses
  rescue_from StandardError, with: :render_500
  rescue_from ActiveRecord::RecordNotFound, with: :render_404
  rescue_from ActionController::ParameterMissing, with: :render_400
  rescue_from ActiveRecord::RecordInvalid, with: :render_422
  rescue_from Pagy::OverflowError, with: :render_400
  rescue_from Pundit::NotAuthorizedError, with: :render_403

  private

  def pagination_params
    limit = params[:limit].presence || 20
    cursor = params[:cursor].presence || 1
    sort_by = params[:sortBy].presence
    sort_order = params[:sortOrder].presence || 'asc'

    {
      page: cursor.to_i,
      per_page: limit.to_i,
      sort_by: sort_by,
      sort_order: sort_order
    }
  end

  def include_params
    params[:include].present? ? params[:include].split(",") : []
  end

  def render_400(error)
    render_error(error, :bad_request)
  end

  def render_404(error)
    render_error(error, :not_found)
  end

  def render_422(error)
    render_error(error, :unprocessable_entity)
  end

  def render_403(error)
    render_error(error, :forbidden)
  end

  def render_500(error)
    render_error(error, :internal_server_error)
  end

  def render_error(error, status)
    error_response = {
      status: status,
      error: {
        code: status,
        message: error.message
      }
    }

    # Add validation errors if present
    if error.respond_to?(:record) && error.record.respond_to?(:errors)
      error_response[:error][:details] = error.record.errors.messages
    end

    # Add backtrace in development
    if Rails.env.development?
      error_response[:error][:backtrace] = error.backtrace&.first(10)
    end

    render json: error_response, status: status
  end
end
