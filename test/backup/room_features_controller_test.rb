require "test_helper"

class RoomFeaturesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @room_feature = room_features(:one)
  end

  test "should get index" do
    get room_features_url, as: :json
    assert_response :success
  end

  test "should create room_feature" do
    assert_difference("RoomFeature.count") do
      post room_features_url, params: { room_feature: { createdAt: @room_feature.createdAt, featureId: @room_feature.featureId, isActive: @room_feature.isActive, operationRoomId: @room_feature.operationRoomId, updatedAt: @room_feature.updatedAt } }, as: :json
    end

    assert_response :created
  end

  test "should show room_feature" do
    get room_feature_url(@room_feature), as: :json
    assert_response :success
  end

  test "should update room_feature" do
    patch room_feature_url(@room_feature), params: { room_feature: { createdAt: @room_feature.createdAt, featureId: @room_feature.featureId, isActive: @room_feature.isActive, operationRoomId: @room_feature.operationRoomId, updatedAt: @room_feature.updatedAt } }, as: :json
    assert_response :success
  end

  test "should destroy room_feature" do
    assert_difference("RoomFeature.count", -1) do
      delete room_feature_url(@room_feature), as: :json
    end

    assert_response :no_content
  end
end
