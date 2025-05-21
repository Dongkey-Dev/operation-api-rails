require "test_helper"

class PlansControllerTest < ActionDispatch::IntegrationTest
  setup do
    @plan = plans(:one)
  end

  test "should get index" do
    get plans_url, as: :json
    assert_response :success
  end

  test "should create plan" do
    assert_difference("Plan.count") do
      post plans_url, params: { plan: { createdAt: @plan.createdAt, description: @plan.description, features: @plan.features, name: @plan.name, price: @plan.price, updatedAt: @plan.updatedAt } }, as: :json
    end

    assert_response :created
  end

  test "should show plan" do
    get plan_url(@plan), as: :json
    assert_response :success
  end

  test "should update plan" do
    patch plan_url(@plan), params: { plan: { createdAt: @plan.createdAt, description: @plan.description, features: @plan.features, name: @plan.name, price: @plan.price, updatedAt: @plan.updatedAt } }, as: :json
    assert_response :success
  end

  test "should destroy plan" do
    assert_difference("Plan.count", -1) do
      delete plan_url(@plan), as: :json
    end

    assert_response :no_content
  end
end
