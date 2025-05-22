require "test_helper"

class CustomersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @api_v1_customer = api_v1_customers(:one)
  end

  test "should get index" do
    get api_v1_customers_url, as: :json
    assert_response :success
  end

  test "should create api_v1_customer" do
    assert_difference("Customer.count") do
      post api_v1_customers_url, params: { api_v1_customer: { createdAt: @api_v1_customer.createdAt, email: @api_v1_customer.email, lastLoginAt: @api_v1_customer.lastLoginAt, name: @api_v1_customer.name, password: @api_v1_customer.password, phoneNumber: @api_v1_customer.phoneNumber, updatedAt: @api_v1_customer.updatedAt, userId: @api_v1_customer.userId } }, as: :json
    end

    assert_response :created
  end

  test "should show api_v1_customer" do
    get api_v1_customer_url(@api_v1_customer), as: :json
    assert_response :success
  end

  test "should update api_v1_customer" do
    patch api_v1_customer_url(@api_v1_customer), params: { api_v1_customer: { createdAt: @api_v1_customer.createdAt, email: @api_v1_customer.email, lastLoginAt: @api_v1_customer.lastLoginAt, name: @api_v1_customer.name, password: @api_v1_customer.password, phoneNumber: @api_v1_customer.phoneNumber, updatedAt: @api_v1_customer.updatedAt, userId: @api_v1_customer.userId } }, as: :json
    assert_response :success
  end

  test "should destroy api_v1_customer" do
    assert_difference("Customer.count", -1) do
      delete api_v1_customer_url(@api_v1_customer), as: :json
    end

    assert_response :no_content
  end
end
