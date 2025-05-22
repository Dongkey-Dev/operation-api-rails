require "test_helper"

class Api::V1::CommandResponsesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @api_v1_command_response = api_v1_command_responses(:one)
  end

  test "should get index" do
    get api_v1_command_responses_url, as: :json
    assert_response :success
  end

  test "should create api_v1_command_response" do
    assert_difference("Api::V1::CommandResponse.count") do
      post api_v1_command_responses_url, params: { api_v1_command_response: { commandId: @api_v1_command_response.commandId, content: @api_v1_command_response.content, createdAt: @api_v1_command_response.createdAt, deletedAt: @api_v1_command_response.deletedAt, isActive: @api_v1_command_response.isActive, isDeleted: @api_v1_command_response.isDeleted, priority: @api_v1_command_response.priority, responseType: @api_v1_command_response.responseType, updatedAt: @api_v1_command_response.updatedAt } }, as: :json
    end

    assert_response :created
  end

  test "should show api_v1_command_response" do
    get api_v1_command_response_url(@api_v1_command_response), as: :json
    assert_response :success
  end

  test "should update api_v1_command_response" do
    patch api_v1_command_response_url(@api_v1_command_response), params: { api_v1_command_response: { commandId: @api_v1_command_response.commandId, content: @api_v1_command_response.content, createdAt: @api_v1_command_response.createdAt, deletedAt: @api_v1_command_response.deletedAt, isActive: @api_v1_command_response.isActive, isDeleted: @api_v1_command_response.isDeleted, priority: @api_v1_command_response.priority, responseType: @api_v1_command_response.responseType, updatedAt: @api_v1_command_response.updatedAt } }, as: :json
    assert_response :success
  end

  test "should destroy api_v1_command_response" do
    assert_difference("Api::V1::CommandResponse.count", -1) do
      delete api_v1_command_response_url(@api_v1_command_response), as: :json
    end

    assert_response :no_content
  end
end
