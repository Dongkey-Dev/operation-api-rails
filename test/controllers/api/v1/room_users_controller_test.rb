require "test_helper"

class RoomUsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @api_v1_room_user = api_v1_room_users(:one)
  end

  test "should get index" do
    get api_v1_room_users_url, as: :json
    assert_response :success
  end

  test "should create api_v1_room_user" do
    assert_difference("RoomUser.count") do
      post api_v1_room_users_url, params: { api_v1_room_user: { joinedAt: @api_v1_room_user.joinedAt, leftAt: @api_v1_room_user.leftAt, nickname: @api_v1_room_user.nickname, operationRoomId: @api_v1_room_user.operationRoomId, role: @api_v1_room_user.role, userId: @api_v1_room_user.userId } }, as: :json
    end

    assert_response :created
  end

  test "should show api_v1_room_user" do
    get api_v1_room_user_url(@api_v1_room_user), as: :json
    assert_response :success
  end

  test "should update api_v1_room_user" do
    patch api_v1_room_user_url(@api_v1_room_user), params: { api_v1_room_user: { joinedAt: @api_v1_room_user.joinedAt, leftAt: @api_v1_room_user.leftAt, nickname: @api_v1_room_user.nickname, operationRoomId: @api_v1_room_user.operationRoomId, role: @api_v1_room_user.role, userId: @api_v1_room_user.userId } }, as: :json
    assert_response :success
  end

  test "should destroy api_v1_room_user" do
    assert_difference("RoomUser.count", -1) do
      delete api_v1_room_user_url(@api_v1_room_user), as: :json
    end

    assert_response :no_content
  end
end
