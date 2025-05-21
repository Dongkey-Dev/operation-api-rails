require "test_helper"

class Api::V1::PlansControllerTest < ActionDispatch::IntegrationTest
  setup do
    @api_v1_plan = api_v1_plans(:one)
  end

  test "should get index" do
    get api_v1_plans_url, as: :json
    assert_response :success
  end

  test "should create api_v1_plan" do
    assert_difference("Api::V1::Plan.count") do
      post api_v1_plans_url, params: { api_v1_plan: { createdAt: @api_v1_plan.createdAt, description: @api_v1_plan.description, features: @api_v1_plan.features, name: @api_v1_plan.name, price: @api_v1_plan.price, updatedAt: @api_v1_plan.updatedAt } }, as: :json
    end

    assert_response :created
  end

  test "should show api_v1_plan" do
    get api_v1_plan_url(@api_v1_plan), as: :json
    assert_response :success
  end

  test "should update api_v1_plan" do
    patch api_v1_plan_url(@api_v1_plan), params: { api_v1_plan: { createdAt: @api_v1_plan.createdAt, description: @api_v1_plan.description, features: @api_v1_plan.features, name: @api_v1_plan.name, price: @api_v1_plan.price, updatedAt: @api_v1_plan.updatedAt } }, as: :json
    assert_response :success
  end

  test "should destroy api_v1_plan" do
    assert_difference("Api::V1::Plan.count", -1) do
      delete api_v1_plan_url(@api_v1_plan), as: :json
    end

    assert_response :no_content
  end
end
