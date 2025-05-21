class Api::V1::CustomersController < ApplicationController
  before_action :set_api_v1_customer, only: %i[ show update destroy ]

  # GET /api/v1/customers
  def index
    @api_v1_customers = Api::V1::Customer.all

    render json: @api_v1_customers
  end

  # GET /api/v1/customers/1
  def show
    render json: @api_v1_customer
  end

  # POST /api/v1/customers
  def create
    @api_v1_customer = Api::V1::Customer.new(api_v1_customer_params)

    if @api_v1_customer.save
      render json: @api_v1_customer, status: :created, location: @api_v1_customer
    else
      render json: @api_v1_customer.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/customers/1
  def update
    if @api_v1_customer.update(api_v1_customer_params)
      render json: @api_v1_customer
    else
      render json: @api_v1_customer.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/customers/1
  def destroy
    @api_v1_customer.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_api_v1_customer
      @api_v1_customer = Api::V1::Customer.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def api_v1_customer_params
      params.expect(api_v1_customer: [ :userId, :name, :email, :phoneNumber, :password, :lastLoginAt, :createdAt, :updatedAt ])
    end
end
