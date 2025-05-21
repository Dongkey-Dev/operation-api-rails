require "test_helper"

class RoomPlanHistoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @room_plan_history = room_plan_histories(:one)
  end

  test "should get index" do
    get room_plan_histories_url, as: :json
    assert_response :success
  end

  test "should create room_plan_history" do
    assert_difference("RoomPlanHistory.count") do
      post room_plan_histories_url, params: { room_plan_history: { createdAt: @room_plan_history.createdAt, endDate: @room_plan_history.endDate, operationRoomId: @room_plan_history.operationRoomId, planId: @room_plan_history.planId, startDate: @room_plan_history.startDate } }, as: :json
    end

    assert_response :created
  end

  test "should show room_plan_history" do
    get room_plan_history_url(@room_plan_history), as: :json
    assert_response :success
  end

  test "should update room_plan_history" do
    patch room_plan_history_url(@room_plan_history), params: { room_plan_history: { createdAt: @room_plan_history.createdAt, endDate: @room_plan_history.endDate, operationRoomId: @room_plan_history.operationRoomId, planId: @room_plan_history.planId, startDate: @room_plan_history.startDate } }, as: :json
    assert_response :success
  end

  test "should destroy room_plan_history" do
    assert_difference("RoomPlanHistory.count", -1) do
      delete room_plan_history_url(@room_plan_history), as: :json
    end

    assert_response :no_content
  end
end
