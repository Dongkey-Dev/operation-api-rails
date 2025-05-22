class Api::V1::CustomersController < ApplicationController
  before_action :set_api_v1_customer, only: %i[ show update destroy show_restful ]

  # Define scopes that can be used for filtering
  has_scope :by_user, as: :user_id
  has_scope :search_by_name, as: :name
  has_scope :search_by_email, as: :email
  has_scope :with_recent_login, as: :recent_days, type: :integer

  # GET /api/v1/customers
  def index
    pagination = pagination_params
    # includes 변수는 현재 사용되지 않지만 나중에 필요할 수 있음

    # Apply scopes from has_scope
    @customers = apply_scopes(Api::V1::Customer).all

    # Apply sorting
    if pagination[:sort_by].present?
      @customers = @customers.order(pagination[:sort_by] => pagination[:sort_order])
    end

    # Apply cursor-based pagination
    if pagination[:cursor].present?
      @customers = @customers.where("id > ?", pagination[:cursor])
    end

    # Apply limit
    if pagination[:limit].present?
      @customers = @customers.limit(pagination[:limit])
    end

    response = {
      data: @customers,
      meta: {
        total: apply_scopes(Api::V1::Customer).count,
        cursor: @customers.last&.id,
        limit: pagination[:limit]
      }
    }

    render json: response
  end

  # GET /api/v1/customers/1
  def show
    render json: { data: @api_v1_customer }
  end

  # GET /api/v1/customers/by-user-id/:user_id
  def by_user_id
    @customer = Api::V1::Customer.find_by!(user_id: params[:user_id])
    render json: { data: @customer }
  end

  # GET /api/v1/customers/by-email/:email
  def by_email
    @customer = Api::V1::Customer.find_by!(email: params[:email])
    render json: { data: @customer }
  end

  # GET /api/v1/customers/restful
  def index_restful
    pagination = pagination_params
    includes = include_params

    # Apply scopes from has_scope
    @customers = apply_scopes(Api::V1::Customer).all

    # Apply sorting
    if pagination[:sort_by].present?
      @customers = @customers.order(pagination[:sort_by] => pagination[:sort_order])
    end

    # Apply cursor-based pagination
    if pagination[:cursor].present?
      @customers = @customers.where("id > ?", pagination[:cursor])
    end

    # Apply limit
    if pagination[:limit].present?
      @customers = @customers.limit(pagination[:limit])
    end

    result = @customers.map do |customer|
      customer_data = customer.as_json

      if includes.include?("adminRooms")
        customer_data["admin_rooms"] = customer.customer_admin_rooms.as_json
      end

      if includes.include?("roomUsers")
        customer_data["room_users"] = Api::V1::RoomUser.where(user_id: customer.user_id).as_json
      end

      customer_data
    end

    response = {
      data: result,
      meta: {
        total: apply_scopes(Api::V1::Customer).count,
        cursor: @customers.last&.id,
        limit: pagination[:limit]
      }
    }

    render json: response
  end

  # GET /api/v1/customers/restful/:id
  def show_restful
    includes = include_params
    customer_data = @api_v1_customer.as_json

    if includes.include?("adminRooms")
      customer_data["admin_rooms"] = @api_v1_customer.customer_admin_rooms.as_json
    end

    if includes.include?("roomUsers")
      customer_data["room_users"] = Api::V1::RoomUser.where(user_id: @api_v1_customer.user_id).as_json
    end

    render json: { data: customer_data }
  end

  # POST /api/v1/customers
  def create
    @customer = Api::V1::Customer.new(api_v1_customer_params)

    if @customer.save
      render json: { data: @customer }, status: :created
    else
      render json: { errors: @customer.errors }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/customers/1
  def update
    if @api_v1_customer.update(api_v1_customer_params)
      render json: { data: @api_v1_customer }
    else
      render json: { errors: @api_v1_customer.errors }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/customers/1
  def destroy
    @api_v1_customer.destroy!
    render json: { message: "Customer successfully deleted" }, status: :ok
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_api_v1_customer
      @api_v1_customer = Api::V1::Customer.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Customer not found" }, status: :not_found
    end

    # Only allow a list of trusted parameters through.
    def api_v1_customer_params
      params.require(:customer).permit(:user_id, :name, :email, :phone_number, :password, :last_login_at, :created_at, :updated_at)
    end
end
