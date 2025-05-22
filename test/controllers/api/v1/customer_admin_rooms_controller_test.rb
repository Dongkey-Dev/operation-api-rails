require "test_helper"

class CustomerAdminRoomsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @api_v1_customer_admin_room = api_v1_customer_admin_rooms(:one)
  end

  test "should get index" do
    get api_v1_customer_admin_rooms_url, as: :json
    assert_response :success
  end

  test "should create api_v1_customer_admin_room" do
    assert_difference("CustomerAdminRoom.count") do
      post api_v1_customer_admin_rooms_url, params: { api_v1_customer_admin_room: { adminRoomId: @api_v1_customer_admin_room.adminRoomId, createdAt: @api_v1_customer_admin_room.createdAt, customerId: @api_v1_customer_admin_room.customerId, isActive: @api_v1_customer_admin_room.isActive } }, as: :json
    end

    assert_response :created
  end

  test "should show api_v1_customer_admin_room" do
    get api_v1_customer_admin_room_url(@api_v1_customer_admin_room), as: :json
    assert_response :success
  end

  test "should update api_v1_customer_admin_room" do
    patch api_v1_customer_admin_room_url(@api_v1_customer_admin_room), params: { api_v1_customer_admin_room: { adminRoomId: @api_v1_customer_admin_room.adminRoomId, createdAt: @api_v1_customer_admin_room.createdAt, customerId: @api_v1_customer_admin_room.customerId, isActive: @api_v1_customer_admin_room.isActive } }, as: :json
    assert_response :success
  end

  test "should destroy api_v1_customer_admin_room" do
    assert_difference("CustomerAdminRoom.count", -1) do
      delete api_v1_customer_admin_room_url(@api_v1_customer_admin_room), as: :json
    end

    assert_response :no_content
  end
end
