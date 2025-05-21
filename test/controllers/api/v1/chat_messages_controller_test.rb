require "test_helper"

class Api::V1::ChatMessagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @api_v1_chat_message = api_v1_chat_messages(:one)
  end

  test "should get index" do
    get api_v1_chat_messages_url, as: :json
    assert_response :success
  end

  test "should create api_v1_chat_message" do
    assert_difference("Api::V1::ChatMessage.count") do
      post api_v1_chat_messages_url, params: { api_v1_chat_message: { _id: @api_v1_chat_message._id, content: @api_v1_chat_message.content, createdAt: @api_v1_chat_message.createdAt, operationRoomId: @api_v1_chat_message.operationRoomId, userId: @api_v1_chat_message.userId } }, as: :json
    end

    assert_response :created
  end

  test "should show api_v1_chat_message" do
    get api_v1_chat_message_url(@api_v1_chat_message), as: :json
    assert_response :success
  end

  test "should update api_v1_chat_message" do
    patch api_v1_chat_message_url(@api_v1_chat_message), params: { api_v1_chat_message: { _id: @api_v1_chat_message._id, content: @api_v1_chat_message.content, createdAt: @api_v1_chat_message.createdAt, operationRoomId: @api_v1_chat_message.operationRoomId, userId: @api_v1_chat_message.userId } }, as: :json
    assert_response :success
  end

  test "should destroy api_v1_chat_message" do
    assert_difference("Api::V1::ChatMessage.count", -1) do
      delete api_v1_chat_message_url(@api_v1_chat_message), as: :json
    end

    assert_response :no_content
  end
end
