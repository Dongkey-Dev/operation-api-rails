require "test_helper"

class RoomFeaturesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @api_v1_room_feature = api_v1_room_features(:one)
  end

  test "should get index" do
    get api_v1_room_features_url, as: :json
    assert_response :success
  end

  test "should create api_v1_room_feature" do
    assert_difference("RoomFeature.count") do
      post api_v1_room_features_url, params: { api_v1_room_feature: { createdAt: @api_v1_room_feature.createdAt, featureId: @api_v1_room_feature.featureId, isActive: @api_v1_room_feature.isActive, operationRoomId: @api_v1_room_feature.operationRoomId, updatedAt: @api_v1_room_feature.updatedAt } }, as: :json
    end

    assert_response :created
  end

  test "should show api_v1_room_feature" do
    get api_v1_room_feature_url(@api_v1_room_feature), as: :json
    assert_response :success
  end

  test "should update api_v1_room_feature" do
    patch api_v1_room_feature_url(@api_v1_room_feature), params: { api_v1_room_feature: { createdAt: @api_v1_room_feature.createdAt, featureId: @api_v1_room_feature.featureId, isActive: @api_v1_room_feature.isActive, operationRoomId: @api_v1_room_feature.operationRoomId, updatedAt: @api_v1_room_feature.updatedAt } }, as: :json
    assert_response :success
  end

  test "should destroy api_v1_room_feature" do
    assert_difference("RoomFeature.count", -1) do
      delete api_v1_room_feature_url(@api_v1_room_feature), as: :json
    end

    assert_response :no_content
  end
end
