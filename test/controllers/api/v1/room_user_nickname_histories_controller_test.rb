require "test_helper"

class RoomUserNicknameHistoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @room_user_nickname_history =  room_user_nickname_histories(:one)
  end

  test "should get index" do
    get room_user_nickname_histories_url, as: :json
    assert_response :success
  end

  test "should create  room_user_nickname_history" do
    assert_difference("RoomUserNicknameHistory.count") do
      post room_user_nickname_histories_url, params: {  room_user_nickname_history: { chatRoomId: @room_user_nickname_history.chatRoomId, createdAt: @room_user_nickname_history.createdAt, deletedAt: @room_user_nickname_history.deletedAt, isDeleted: @room_user_nickname_history.isDeleted, newNickname: @room_user_nickname_history.newNickname, previousNickname: @room_user_nickname_history.previousNickname, userId: @room_user_nickname_history.userId } }, as: :json
    end

    assert_response :created
  end

  test "should show  room_user_nickname_history" do
    get room_user_nickname_history_url(@room_user_nickname_history), as: :json
    assert_response :success
  end

  test "should update  room_user_nickname_history" do
    patch room_user_nickname_history_url(@room_user_nickname_history), params: {  room_user_nickname_history: { chatRoomId: @room_user_nickname_history.chatRoomId, createdAt: @room_user_nickname_history.createdAt, deletedAt: @room_user_nickname_history.deletedAt, isDeleted: @room_user_nickname_history.isDeleted, newNickname: @room_user_nickname_history.newNickname, previousNickname: @room_user_nickname_history.previousNickname, userId: @room_user_nickname_history.userId } }, as: :json
    assert_response :success
  end

  test "should destroy  room_user_nickname_history" do
    assert_difference("RoomUserNicknameHistory.count", -1) do
      delete room_user_nickname_history_url(@room_user_nickname_history), as: :json
    end

    assert_response :no_content
  end
end
