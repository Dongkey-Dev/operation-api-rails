class Api::V1::AttendancesController < ApiController
  include CursorPagination
  include Pagy::Backend

  before_action :authenticate_user
  before_action :set_attendance, only: %i[destroy]

  # Define scopes that can be used for filtering
  has_scope :by_operation_room
  has_scope :by_user

  # GET /api/v1/attendances
  def index
    # Validate scope parameters
    param! :operation_room_id, Integer, transform: :presence
    param! :user_id, Integer, transform: :presence

    # Build base query with scopes and authorize with policy_scope
    @resources = policy_scope(apply_scopes(Attendance)).order(created_at: :desc)

    # Apply cursor pagination
    @resources = apply_cursor_pagination(@resources)
    total_count = @resources.except(:limit, :offset).count

    # Get the last record for next cursor
    last_record = @resources.last
    next_cursor = last_record ? encode_cursor(last_record, cursor_params[:order_by]) : nil

    render json: {
      data: @resources,
      meta: {
        pagination: {
          per_page: cursor_params[:limit],
          total_count: total_count,
          next_cursor: next_cursor
        }
      }
    }
  end

  # POST /api/v1/attendances
  def create
    @attendance = Attendance.new(attendance_params)

    # Authorize the attendance creation
    authorize @attendance

    if @attendance.save
      render json: {
        data: @attendance
      }, status: :created
    else
      render json: {
        errors: format_errors(@attendance.errors)
      }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/attendances/:id
  def destroy
    # Authorize the attendance deletion
    authorize @attendance

    @attendance.destroy!
    head :no_content
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_attendance
    @attendance = Attendance.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: {
      error: {
        code: "not_found",
        message: "Attendance not found"
      }
    }, status: :not_found
  end

  # Only allow a list of trusted parameters through.
  def attendance_params
    params.require(:attendance).permit(:user_id, :operation_room_id)
  end

  # Format ActiveRecord errors in a consistent way
  def format_errors(errors)
    errors.map do |error|
      {
        field: error.attribute,
        message: error.message,
        code: error_code_for(error.attribute)
      }
    end
  end

  # Map error attributes to error codes
  def error_code_for(attribute)
    {
      user_id: "invalid_user_id",
      operation_room_id: "invalid_operation_room_id"
    }[attribute.to_sym] || "validation_error"
  end
end
