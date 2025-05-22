require "test_helper"

class RoomUsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @room_user =  room_users(:one)
  end

  test "should get index" do
    get room_users_url, as: :json
    assert_response :success
  end

  test "should create  room_user" do
    assert_difference("RoomUser.count") do
      post room_users_url, params: {  room_user: { joinedAt: @room_user.joinedAt, leftAt: @room_user.leftAt, nickname: @room_user.nickname, operationRoomId: @room_user.operationRoomId, role: @room_user.role, userId: @room_user.userId } }, as: :json
    end

    assert_response :created
  end

  test "should show  room_user" do
    get room_user_url(@room_user), as: :json
    assert_response :success
  end

  test "should update  room_user" do
    patch room_user_url(@room_user), params: {  room_user: { joinedAt: @room_user.joinedAt, leftAt: @room_user.leftAt, nickname: @room_user.nickname, operationRoomId: @room_user.operationRoomId, role: @room_user.role, userId: @room_user.userId } }, as: :json
    assert_response :success
  end

  test "should destroy  room_user" do
    assert_difference("RoomUser.count", -1) do
      delete room_user_url(@room_user), as: :json
    end

    assert_response :no_content
  end
end
