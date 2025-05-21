require "test_helper"

class Api::V1::RoomUserNicknameHistoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @api_v1_room_user_nickname_history = api_v1_room_user_nickname_histories(:one)
  end

  test "should get index" do
    get api_v1_room_user_nickname_histories_url, as: :json
    assert_response :success
  end

  test "should create api_v1_room_user_nickname_history" do
    assert_difference("Api::V1::RoomUserNicknameHistory.count") do
      post api_v1_room_user_nickname_histories_url, params: { api_v1_room_user_nickname_history: { chatRoomId: @api_v1_room_user_nickname_history.chatRoomId, createdAt: @api_v1_room_user_nickname_history.createdAt, deletedAt: @api_v1_room_user_nickname_history.deletedAt, isDeleted: @api_v1_room_user_nickname_history.isDeleted, newNickname: @api_v1_room_user_nickname_history.newNickname, previousNickname: @api_v1_room_user_nickname_history.previousNickname, userId: @api_v1_room_user_nickname_history.userId } }, as: :json
    end

    assert_response :created
  end

  test "should show api_v1_room_user_nickname_history" do
    get api_v1_room_user_nickname_history_url(@api_v1_room_user_nickname_history), as: :json
    assert_response :success
  end

  test "should update api_v1_room_user_nickname_history" do
    patch api_v1_room_user_nickname_history_url(@api_v1_room_user_nickname_history), params: { api_v1_room_user_nickname_history: { chatRoomId: @api_v1_room_user_nickname_history.chatRoomId, createdAt: @api_v1_room_user_nickname_history.createdAt, deletedAt: @api_v1_room_user_nickname_history.deletedAt, isDeleted: @api_v1_room_user_nickname_history.isDeleted, newNickname: @api_v1_room_user_nickname_history.newNickname, previousNickname: @api_v1_room_user_nickname_history.previousNickname, userId: @api_v1_room_user_nickname_history.userId } }, as: :json
    assert_response :success
  end

  test "should destroy api_v1_room_user_nickname_history" do
    assert_difference("Api::V1::RoomUserNicknameHistory.count", -1) do
      delete api_v1_room_user_nickname_history_url(@api_v1_room_user_nickname_history), as: :json
    end

    assert_response :no_content
  end
end
