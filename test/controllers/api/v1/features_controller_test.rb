require "test_helper"

class Api::V1::FeaturesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @api_v1_feature = api_v1_features(:one)
  end

  test "should get index" do
    get api_v1_features_url, as: :json
    assert_response :success
  end

  test "should create api_v1_feature" do
    assert_difference("Api::V1::Feature.count") do
      post api_v1_features_url, params: { api_v1_feature: { createdAt: @api_v1_feature.createdAt, description: @api_v1_feature.description, name: @api_v1_feature.name, updatedAt: @api_v1_feature.updatedAt } }, as: :json
    end

    assert_response :created
  end

  test "should show api_v1_feature" do
    get api_v1_feature_url(@api_v1_feature), as: :json
    assert_response :success
  end

  test "should update api_v1_feature" do
    patch api_v1_feature_url(@api_v1_feature), params: { api_v1_feature: { createdAt: @api_v1_feature.createdAt, description: @api_v1_feature.description, name: @api_v1_feature.name, updatedAt: @api_v1_feature.updatedAt } }, as: :json
    assert_response :success
  end

  test "should destroy api_v1_feature" do
    assert_difference("Api::V1::Feature.count", -1) do
      delete api_v1_feature_url(@api_v1_feature), as: :json
    end

    assert_response :no_content
  end
end
