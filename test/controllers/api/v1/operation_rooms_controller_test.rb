require "test_helper"

class OperationRoomsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @operation_room =  operation_rooms(:one)
  end

  test "should get index" do
    get operation_rooms_url, as: :json
    assert_response :success
  end

  test "should create  operation_room" do
    assert_difference("OperationRoom.count") do
      post operation_rooms_url, params: {  operation_room: { accumulatedPaymentAmount: @operation_room.accumulatedPaymentAmount, chatRoomId: @operation_room.chatRoomId, createdAt: @operation_room.createdAt, customerAdminRoomId: @operation_room.customerAdminRoomId, customerAdminUserId: @operation_room.customerAdminUserId, dueDate: @operation_room.dueDate, openChatLink: @operation_room.openChatLink, originTitle: @operation_room.originTitle, platformType: @operation_room.platformType, roomType: @operation_room.roomType, title: @operation_room.title, updatedAt: @operation_room.updatedAt } }, as: :json
    end

    assert_response :created
  end

  test "should show  operation_room" do
    get operation_room_url(@operation_room), as: :json
    assert_response :success
  end

  test "should update  operation_room" do
    patch operation_room_url(@operation_room), params: {  operation_room: { accumulatedPaymentAmount: @operation_room.accumulatedPaymentAmount, chatRoomId: @operation_room.chatRoomId, createdAt: @operation_room.createdAt, customerAdminRoomId: @operation_room.customerAdminRoomId, customerAdminUserId: @operation_room.customerAdminUserId, dueDate: @operation_room.dueDate, openChatLink: @operation_room.openChatLink, originTitle: @operation_room.originTitle, platformType: @operation_room.platformType, roomType: @operation_room.roomType, title: @operation_room.title, updatedAt: @operation_room.updatedAt } }, as: :json
    assert_response :success
  end

  test "should destroy  operation_room" do
    assert_difference("OperationRoom.count", -1) do
      delete operation_room_url(@operation_room), as: :json
    end

    assert_response :no_content
  end
end
