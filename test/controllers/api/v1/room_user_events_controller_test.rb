require "test_helper"

class RoomUserEventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @api_v1_room_user_event = api_v1_room_user_events(:one)
  end

  test "should get index" do
    get api_v1_room_user_events_url, as: :json
    assert_response :success
  end

  test "should create api_v1_room_user_event" do
    assert_difference("RoomUserEvent.count") do
      post api_v1_room_user_events_url, params: { api_v1_room_user_event: { eventAt: @api_v1_room_user_event.eventAt, eventType: @api_v1_room_user_event.eventType, operationRoomId: @api_v1_room_user_event.operationRoomId, userId: @api_v1_room_user_event.userId } }, as: :json
    end

    assert_response :created
  end

  test "should show api_v1_room_user_event" do
    get api_v1_room_user_event_url(@api_v1_room_user_event), as: :json
    assert_response :success
  end

  test "should update api_v1_room_user_event" do
    patch api_v1_room_user_event_url(@api_v1_room_user_event), params: { api_v1_room_user_event: { eventAt: @api_v1_room_user_event.eventAt, eventType: @api_v1_room_user_event.eventType, operationRoomId: @api_v1_room_user_event.operationRoomId, userId: @api_v1_room_user_event.userId } }, as: :json
    assert_response :success
  end

  test "should destroy api_v1_room_user_event" do
    assert_difference("RoomUserEvent.count", -1) do
      delete api_v1_room_user_event_url(@api_v1_room_user_event), as: :json
    end

    assert_response :no_content
  end
end
