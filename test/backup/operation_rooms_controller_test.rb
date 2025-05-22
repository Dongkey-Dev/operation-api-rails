require "test_helper"

class Api::V1::OperationRoomsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @api_v1_operation_room = api_v1_operation_rooms(:one)
  end

  test "should get index" do
    get api_v1_operation_rooms_url, as: :json
    assert_response :success
  end

  test "should create api_v1_operation_room" do
    assert_difference("Api::V1::OperationRoom.count") do
      post api_v1_operation_rooms_url, params: { api_v1_operation_room: { accumulatedPaymentAmount: @api_v1_operation_room.accumulatedPaymentAmount, chatRoomId: @api_v1_operation_room.chatRoomId, createdAt: @api_v1_operation_room.createdAt, customerAdminRoomId: @api_v1_operation_room.customerAdminRoomId, customerAdminUserId: @api_v1_operation_room.customerAdminUserId, dueDate: @api_v1_operation_room.dueDate, openChatLink: @api_v1_operation_room.openChatLink, originTitle: @api_v1_operation_room.originTitle, platformType: @api_v1_operation_room.platformType, roomType: @api_v1_operation_room.roomType, title: @api_v1_operation_room.title, updatedAt: @api_v1_operation_room.updatedAt } }, as: :json
    end

    assert_response :created
  end

  test "should show api_v1_operation_room" do
    get api_v1_operation_room_url(@api_v1_operation_room), as: :json
    assert_response :success
  end

  test "should update api_v1_operation_room" do
    patch api_v1_operation_room_url(@api_v1_operation_room), params: { api_v1_operation_room: { accumulatedPaymentAmount: @api_v1_operation_room.accumulatedPaymentAmount, chatRoomId: @api_v1_operation_room.chatRoomId, createdAt: @api_v1_operation_room.createdAt, customerAdminRoomId: @api_v1_operation_room.customerAdminRoomId, customerAdminUserId: @api_v1_operation_room.customerAdminUserId, dueDate: @api_v1_operation_room.dueDate, openChatLink: @api_v1_operation_room.openChatLink, originTitle: @api_v1_operation_room.originTitle, platformType: @api_v1_operation_room.platformType, roomType: @api_v1_operation_room.roomType, title: @api_v1_operation_room.title, updatedAt: @api_v1_operation_room.updatedAt } }, as: :json
    assert_response :success
  end

  test "should destroy api_v1_operation_room" do
    assert_difference("Api::V1::OperationRoom.count", -1) do
      delete api_v1_operation_room_url(@api_v1_operation_room), as: :json
    end

    assert_response :no_content
  end
end
