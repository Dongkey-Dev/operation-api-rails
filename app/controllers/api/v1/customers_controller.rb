class Api::V1::CustomersController < ApplicationController
  before_action :set_customer, only: %i[ show update destroy show_restful ]

  # Define scopes that can be used for filtering
  has_scope :by_user, as: :user_id
  has_scope :search_by_name, as: :name
  has_scope :search_by_email, as: :email
  has_scope :with_recent_login, as: :recent_days

  # GET /api/v1/customers
  def index
    # Validate scope parameters
    param! :user_id, Integer, transform: :presence
    param! :name, String, transform: :strip
    param! :email, String, transform: :strip
    param! :recent_days, Integer, transform: :presence

    pagination = pagination_params
    @resources = apply_scopes(Customer).order(created_at: :desc)
    
    if params[:cursor].present?
      cursor_time = Time.zone.parse(params[:cursor])
      @resources = @resources.where('created_at < ?', cursor_time)
    end

    if params[:include].present?
      includes = params[:include].split(',')
      @resources = @resources.includes(includes)
    end
    
    @resources = @resources.limit(pagination[:per_page])
    total_count = @resources.except(:limit, :offset).count
    next_cursor = @resources.last&.created_at&.iso8601

    render json: {
      data: @resources.as_json(include: params[:include]&.split(',')),
      pagination: {
        per_page: pagination[:per_page],
        total_count: total_count,
        next_cursor: next_cursor
      }
    }
  end

  # GET /api/v1/customers/1
  def show
    render json: { data: @customer }
  end

  # GET /api/v1/customers/by-user-id/:user_id
  def by_user_id
    @customer = Customer.find_by!(user_id: params[:user_id])
    render json: { data: @customer }
  end

  # GET /api/v1/customers/by-email/:email
  def by_email
    @customer = Customer.find_by!(email: params[:email])
    render json: { data: @customer }
  end

  # GET /api/v1/customers/restful
  def index_restful
    # Get pagination and include params
    pagination = pagination_params
    includes = include_params

    # Build base query with scopes and sorting
    base_query = apply_scopes(Customer)

    if pagination[:sort_by].present?
      base_query = base_query.order(pagination[:sort_by] => pagination[:sort_order])
    end

    # Apply Pagy pagination
    @pagy, @customers = pagy(base_query, items: 20)

    # Process includes
    result = @customers.map do |customer|
      customer_data = customer.as_json

      if includes.include?("adminRooms")
        customer_data["admin_rooms"] = customer.customer_admin_rooms.as_json
      end

      if includes.include?("roomUsers")
        customer_data["room_users"] = RoomUser.where(user_id: customer.user_id).as_json
      end

      customer_data
    end

    # Render response with Pagy metadata
    render json: {
      data: result,
      pagy: {
        page: @pagy.page,
        items: @pagy.items,
        pages: @pagy.pages,
        count: @pagy.count
      }
    }
  end

  # GET /api/v1/customers/restful/:id
  def show_restful
    includes = include_params
    customer_data = @customer.as_json

    if includes.include?("adminRooms")
      customer_data["admin_rooms"] = @customer.customer_admin_rooms.as_json
    end

    if includes.include?("roomUsers")
      customer_data["room_users"] = RoomUser.where(user_id: @customer.user_id).as_json
    end

    render json: { data: customer_data }
  end

  # POST /api/v1/customers
  def create
    @customer = Customer.new(customer_params)

    if @customer.save
      render json: { data: @customer }, status: :created
    else
      render json: { errors: @customer.errors }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/customers/1
  def update
    if @customer.update(customer_params)
      render json: { data: @customer }
    else
      render json: { errors: @customer.errors }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/customers/1
  def destroy
    @customer.destroy!
    render json: { message: "Customer successfully deleted" }, status: :ok
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_customer
      @customer = Customer.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Customer not found" }, status: :not_found
    end

    # Only allow a list of trusted parameters through.
    def customer_params
      params.require(:customer).permit(:user_id, :name, :email, :phone_number, :password, :last_login_at)
    end
end
