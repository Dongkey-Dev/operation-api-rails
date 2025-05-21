require "test_helper"

class Api::V1::RoomPlanHistoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @api_v1_room_plan_history = api_v1_room_plan_histories(:one)
  end

  test "should get index" do
    get api_v1_room_plan_histories_url, as: :json
    assert_response :success
  end

  test "should create api_v1_room_plan_history" do
    assert_difference("Api::V1::RoomPlanHistory.count") do
      post api_v1_room_plan_histories_url, params: { api_v1_room_plan_history: { createdAt: @api_v1_room_plan_history.createdAt, endDate: @api_v1_room_plan_history.endDate, operationRoomId: @api_v1_room_plan_history.operationRoomId, planId: @api_v1_room_plan_history.planId, startDate: @api_v1_room_plan_history.startDate } }, as: :json
    end

    assert_response :created
  end

  test "should show api_v1_room_plan_history" do
    get api_v1_room_plan_history_url(@api_v1_room_plan_history), as: :json
    assert_response :success
  end

  test "should update api_v1_room_plan_history" do
    patch api_v1_room_plan_history_url(@api_v1_room_plan_history), params: { api_v1_room_plan_history: { createdAt: @api_v1_room_plan_history.createdAt, endDate: @api_v1_room_plan_history.endDate, operationRoomId: @api_v1_room_plan_history.operationRoomId, planId: @api_v1_room_plan_history.planId, startDate: @api_v1_room_plan_history.startDate } }, as: :json
    assert_response :success
  end

  test "should destroy api_v1_room_plan_history" do
    assert_difference("Api::V1::RoomPlanHistory.count", -1) do
      delete api_v1_room_plan_history_url(@api_v1_room_plan_history), as: :json
    end

    assert_response :no_content
  end
end
