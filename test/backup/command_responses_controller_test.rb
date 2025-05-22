require "test_helper"

class Api::V1::CommandResponsesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @command_response =  command_responses(:one)
  end

  test "should get index" do
    get command_responses_url, as: :json
    assert_response :success
  end

  test "should create  command_response" do
    assert_difference("Api::V1::CommandResponse.count") do
      post command_responses_url, params: {  command_response: { commandId: @command_response.commandId, content: @command_response.content, createdAt: @command_response.createdAt, deletedAt: @command_response.deletedAt, isActive: @command_response.isActive, isDeleted: @command_response.isDeleted, priority: @command_response.priority, responseType: @command_response.responseType, updatedAt: @command_response.updatedAt } }, as: :json
    end

    assert_response :created
  end

  test "should show  command_response" do
    get command_response_url(@command_response), as: :json
    assert_response :success
  end

  test "should update  command_response" do
    patch command_response_url(@command_response), params: { command_response: { commandId: @command_response.commandId, content: @command_response.content, createdAt: @command_response.createdAt, deletedAt: @command_response.deletedAt, isActive: @command_response.isActive, isDeleted: @command_response.isDeleted, priority: @command_response.priority, responseType: @command_response.responseType, updatedAt: @command_response.updatedAt } }, as: :json
    assert_response :success
  end

  test "should destroy  command_response" do
    assert_difference("CommandResponse.count", -1) do
      delete command_response_url(@command_response), as: :json
    end

    assert_response :no_content
  end
end
