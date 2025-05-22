require "test_helper"

class CustomerAdminRoomsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @customer_admin_room =  customer_admin_rooms(:one)
  end

  test "should get index" do
    get customer_admin_rooms_url, as: :json
    assert_response :success
  end

  test "should create  customer_admin_room" do
    assert_difference("CustomerAdminRoom.count") do
      post customer_admin_rooms_url, params: {  customer_admin_room: { adminRoomId: @customer_admin_room.adminRoomId, createdAt: @customer_admin_room.createdAt, customerId: @customer_admin_room.customerId, isActive: @customer_admin_room.isActive } }, as: :json
    end

    assert_response :created
  end

  test "should show  customer_admin_room" do
    get customer_admin_room_url(@customer_admin_room), as: :json
    assert_response :success
  end

  test "should update  customer_admin_room" do
    patch customer_admin_room_url(@customer_admin_room), params: {  customer_admin_room: { adminRoomId: @customer_admin_room.adminRoomId, createdAt: @customer_admin_room.createdAt, customerId: @customer_admin_room.customerId, isActive: @customer_admin_room.isActive } }, as: :json
    assert_response :success
  end

  test "should destroy  customer_admin_room" do
    assert_difference("CustomerAdminRoom.count", -1) do
      delete customer_admin_room_url(@customer_admin_room), as: :json
    end

    assert_response :no_content
  end
end
