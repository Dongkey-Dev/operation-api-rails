require "test_helper"

class Api::V1::CommandsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @api_v1_command = api_v1_commands(:one)
  end

  test "should get index" do
    get api_v1_commands_url, as: :json
    assert_response :success
  end

  test "should create api_v1_command" do
    assert_difference("Api::V1::Command.count") do
      post api_v1_commands_url, params: { api_v1_command: { createdAt: @api_v1_command.createdAt, customerId: @api_v1_command.customerId, deletedAt: @api_v1_command.deletedAt, description: @api_v1_command.description, isActive: @api_v1_command.isActive, isDeleted: @api_v1_command.isDeleted, keyword: @api_v1_command.keyword, operationRoomId: @api_v1_command.operationRoomId, updatedAt: @api_v1_command.updatedAt } }, as: :json
    end

    assert_response :created
  end

  test "should show api_v1_command" do
    get api_v1_command_url(@api_v1_command), as: :json
    assert_response :success
  end

  test "should update api_v1_command" do
    patch api_v1_command_url(@api_v1_command), params: { api_v1_command: { createdAt: @api_v1_command.createdAt, customerId: @api_v1_command.customerId, deletedAt: @api_v1_command.deletedAt, description: @api_v1_command.description, isActive: @api_v1_command.isActive, isDeleted: @api_v1_command.isDeleted, keyword: @api_v1_command.keyword, operationRoomId: @api_v1_command.operationRoomId, updatedAt: @api_v1_command.updatedAt } }, as: :json
    assert_response :success
  end

  test "should destroy api_v1_command" do
    assert_difference("Api::V1::Command.count", -1) do
      delete api_v1_command_url(@api_v1_command), as: :json
    end

    assert_response :no_content
  end
end
