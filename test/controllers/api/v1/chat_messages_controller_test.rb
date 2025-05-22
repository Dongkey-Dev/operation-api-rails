require "test_helper"

class ChatMessagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @chat_message =  chat_messages(:one)
  end

  test "should get index" do
    get chat_messages_url, as: :json
    assert_response :success
  end

  test "should create  chat_message" do
    assert_difference("ChatMessage.count") do
      post chat_messages_url, params: {  chat_message: { _id: @chat_message._id, content: @chat_message.content, createdAt: @chat_message.createdAt, operationRoomId: @chat_message.operationRoomId, userId: @chat_message.userId } }, as: :json
    end

    assert_response :created
  end

  test "should show  chat_message" do
    get chat_message_url(@chat_message), as: :json
    assert_response :success
  end

  test "should update  chat_message" do
    patch chat_message_url(@chat_message), params: {  chat_message: { _id: @chat_message._id, content: @chat_message.content, createdAt: @chat_message.createdAt, operationRoomId: @chat_message.operationRoomId, userId: @chat_message.userId } }, as: :json
    assert_response :success
  end

  test "should destroy  chat_message" do
    assert_difference("ChatMessage.count", -1) do
      delete chat_message_url(@chat_message), as: :json
    end

    assert_response :no_content
  end
end
