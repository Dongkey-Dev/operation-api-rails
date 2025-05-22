require "test_helper"

class RoomUserEventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @room_user_event = room_user_events(:one)
  end

  test "should get index" do
    get room_user_events_url, as: :json
    assert_response :success
  end

  test "should create room_user_event" do
    assert_difference("RoomUserEvent.count") do
      post room_user_events_url, params: { room_user_event: { eventAt: @room_user_event.eventAt, eventType: @room_user_event.eventType, operationRoomId: @room_user_event.operationRoomId, userId: @room_user_event.userId } }, as: :json
    end

    assert_response :created
  end

  test "should show room_user_event" do
    get room_user_event_url(@room_user_event), as: :json
    assert_response :success
  end

  test "should update room_user_event" do
    patch room_user_event_url(@room_user_event), params: { room_user_event: { eventAt: @room_user_event.eventAt, eventType: @room_user_event.eventType, operationRoomId: @room_user_event.operationRoomId, userId: @room_user_event.userId } }, as: :json
    assert_response :success
  end

  test "should destroy room_user_event" do
    assert_difference("RoomUserEvent.count", -1) do
      delete room_user_event_url(@room_user_event), as: :json
    end

    assert_response :no_content
  end
end
