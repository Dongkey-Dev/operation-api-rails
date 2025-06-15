class Api::V1::CustomersController < Api::ApiController
  include CursorPagination
  include OperationRoomsIncludable
  include Pagy::Backend

  before_action :authenticate_user
  before_action :set_customer, only: %i[show update destroy]

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

    # Process include parameters
    includes = process_include_params
    has_operation_rooms = includes.delete(:operation_rooms)

    # Build base query with scopes and authorize with policy_scope
    @resources = policy_scope(apply_scopes(Customer)).order(id: :desc)

    # Apply eager loading for included associations
    @resources = @resources.includes(includes) if includes.any?

    # Apply cursor pagination
    @resources = apply_cursor_pagination(@resources)
    total_count = @resources.except(:limit, :offset).count

    # Get the last record for next cursor
    last_record = @resources.last
    next_cursor = last_record ? encode_cursor(last_record, cursor_params[:order_by]) : nil

    # Get the data with standard associations
    include_options = prepare_include_options(includes)
    customer_data = @resources.as_json(include: include_options)

    # Manually handle operation_rooms if requested
    customer_data = add_operation_rooms_to_customers(customer_data, @resources) if has_operation_rooms

    render json: {
      data: customer_data,
      meta: {
        pagination: {
          per_page: cursor_params[:limit],
          total_count: total_count,
          next_cursor: next_cursor
        }
      }
    }
  end

  # GET /api/v1/customers/:token
  def show
    # Find customer by token
    @customer = Customer.find_by_token(params[:token])

    # Return 404 if customer not found
    return render json: { errors: [ { code: "not_found", detail: "Customer not found" } ] }, status: :not_found unless @customer

    # Authorize the customer
    authorize @customer

    # Process include parameters
    includes = process_include_params
    has_operation_rooms = includes.delete(:operation_rooms)

    # Get the data with standard associations
    include_options = prepare_include_options(includes)
    customer_data = @customer.as_json(include: include_options)

    # Manually handle operation_rooms if requested
    customer_data = add_operation_rooms_to_customer(customer_data, @customer) if has_operation_rooms

    render json: { data: customer_data }
  end

  # GET /api/v1/customers/by-user-id/:user_id
  def by_user_id
    # Add logging to debug the user_id parameter
    Rails.logger.info "Looking up customer with user_id: #{params[:user_id]}"

    # Try to find the customer
    @customer = Customer.find_by(user_id: params[:user_id])

    if @customer.nil?
      render json: {
        error: {
          code: "not_found",
          message: "Customer with user_id '#{params[:user_id]}' not found"
        }
      }, status: :not_found
      return
    end

    # Authorize the customer for the by_user_id action
    authorize @customer, :by_user_id?

    # Process include parameters
    includes = process_include_params
    has_operation_rooms = includes.delete(:operation_rooms)

    # Get the data with standard associations
    include_options = prepare_include_options(includes)
    customer_data = @customer.as_json(include: include_options)

    # Manually handle operation_rooms if requested
    customer_data = add_operation_rooms_to_customer(customer_data, @customer) if has_operation_rooms

    render json: { data: customer_data }
  end

  # GET /api/v1/customers/by-email/:email
  def by_email
    # The email parameter may come in URL-encoded form
    email = params[:email]

    # Add logging to debug the email parameter
    Rails.logger.info "Looking up customer with email (raw): #{email}"

    # Try to find the customer with exact match first
    @customer = Customer.find_by(email: email)

    # If not found, try with case-insensitive search
    if @customer.nil?
      @customer = Customer.where("lower(email) = ?", email.downcase).first
    end

    # If still not found, return a 404
    if @customer.nil?
      render json: {
        error: {
          code: "not_found",
          message: "Customer with email '#{email}' not found"
        }
      }, status: :not_found
      return
    end

    # Authorize the customer for the by_email action
    authorize @customer, :by_email?

    # Process include parameters
    includes = process_include_params
    has_operation_rooms = includes.delete(:operation_rooms)

    # Get the data with standard associations
    include_options = prepare_include_options(includes)
    customer_data = @customer.as_json(include: include_options)

    # Manually handle operation_rooms if requested
    customer_data = add_operation_rooms_to_customer(customer_data, @customer) if has_operation_rooms

    render json: { data: customer_data }
  end

  # POST /api/v1/customers
  def create
    @customer = Customer.new(customer_params)

    # Authorize the customer creation
    authorize @customer

    if @customer.save
      render json: { data: @customer }, status: :created
    else
      render json: {
        errors: format_errors(@customer.errors)
      }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/customers/:id
  def update
    # Authorize the customer update
    authorize @customer

    if @customer.update(customer_params)
      render json: { data: @customer }
    else
      render json: {
        errors: format_errors(@customer.errors)
      }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/customers/:id
  def destroy
    # Authorize the customer deletion
    authorize @customer

    @customer.destroy!
    head :no_content
  end

  private



  # Use callbacks to share common setup or constraints between actions.
  def set_customer
    @customer = Customer.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: {
      error: {
        code: "not_found",
        message: "Customer not found"
      }
    }, status: :not_found
  end

  # Only allow a list of trusted parameters through.
  def customer_params
    params.require(:customer).permit(:user_id, :name, :email, :phone_number, :password, :last_login_at)
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
      name: "invalid_name",
      email: "invalid_email",
      phone_number: "invalid_phone_number"
    }[attribute.to_sym] || "validation_error"
  end

  # Override Pundit's current_user method to use current_customer for authorization
  def pundit_user
    current_customer
  end
end
