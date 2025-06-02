require 'rails_helper'

RSpec.describe "Api::V1::OperationRooms", type: :request do
  let(:user) { create(:user) }
  let(:auth_headers) { { 'Authorization' => "Bearer #{generate_token_for(user)}" } }

  # Helper method to generate token (implementation depends on your auth system)
  def generate_token_for(user)
    "test_token_for_#{user.id}"
  end

  describe "GET /api/v1/operation_rooms" do
    before do
      # Create test data
      create_list(:operation_room, 5)
      # Mock authentication and authorization
      allow_any_instance_omf(Api::V1::OperationRoomsController).to receive(:authenticate_user).and_return(true)
      allow_any_instance_of(Api::V1::OperationRoomsController).to receive(:policy_scope).and_return(OperationRoom.all)
    end

    it "returns a paginated list of operation rooms" do
      get "/api/v1/operation_rooms", headers: auth_headers

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)

      expect(json_response["data"]).to be_an(Array)
      expect(json_response["data"].length).to eq(5)
      expect(json_response["meta"]["pagination"]).to include(
        "per_page" => 15,
        "current_page" => 1,
        "total_pages" => 1,
        "total_count" => 5
      )
    end

    it "respects custom page size" do
      get "/api/v1/operation_rooms", params: { limit: 2 }, headers: auth_headers

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)

      expect(json_response["data"].length).to eq(2)
      expect(json_response["meta"]["pagination"]["per_page"]).to eq(2)
    end

    it "includes associated resources when requested" do
      # Create operation room with associated room_users
      operation_room = create(:operation_room)
      create_list(:room_user, 3, operation_room: operation_room)

      get "/api/v1/operation_rooms", params: { include: "room_users" }, headers: auth_headers

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)

      # The first operation room should have room_users included
      expect(json_response["data"].first["room_users"]).to be_an(Array)
    end

    it "limits included associations based on default limits" do
      # Create operation room with many room_users
      operation_room = create(:operation_room)
      create_list(:room_user, 15, operation_room: operation_room)

      get "/api/v1/operation_rooms", params: { include: "room_users" }, headers: auth_headers

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)

      # Should limit to default of 10 room_users
      expect(json_response["data"].first["room_users"].length).to eq(10)
    end

    it "respects custom association limits" do
      # Create operation room with many room_users
      operation_room = create(:operation_room)
      create_list(:room_user, 15, operation_room: operation_room)

      get "/api/v1/operation_rooms", params: { include: "room_users", room_users_limit: 5 }, headers: auth_headers

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)

      # Should limit to specified 5 room_users
      expect(json_response["data"].first["room_users"].length).to eq(5)
    end

    it "handles invalid includes gracefully" do
      get "/api/v1/operation_rooms", params: { include: "invalid_association" }, headers: auth_headers

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)

      # Should return data without includes
      expect(json_response["data"].first).not_to have_key("invalid_association")
    end

    it "handles pagination overflow gracefully" do
      get "/api/v1/operation_rooms", params: { page: 999 }, headers: auth_headers

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)

      # Should return empty data array
      expect(json_response["data"]).to eq([])
      expect(json_response["meta"]["pagination"]["current_page"]).to eq(999)
    end
  end

  describe "GET /api/v1/operation_rooms/:id" do
    let(:operation_room) { create(:operation_room) }

    before do
      # Mock authentication and authorization
      allow_any_instance_of(Api::V1::OperationRoomsController).to receive(:authenticate_user).and_return(true)
      allow_any_instance_of(Api::V1::OperationRoomsController).to receive(:authorize).and_return(true)
    end

    it "returns a single operation room" do
      get "/api/v1/operation_rooms/#{operation_room.id}", headers: auth_headers

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)

      expect(json_response["id"]).to eq(operation_room.id)
    end

    it "includes associated resources when requested" do
      # Create room_users for the operation room
      create_list(:room_user, 3, operation_room: operation_room)

      get "/api/v1/operation_rooms/#{operation_room.id}", params: { include: "room_users" }, headers: auth_headers

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)

      expect(json_response["room_users"]).to be_an(Array)
      expect(json_response["room_users"].length).to eq(3)
    end

    it "limits included associations based on default limits" do
      # Create many room_users for the operation room
      create_list(:room_user, 15, operation_room: operation_room)

      get "/api/v1/operation_rooms/#{operation_room.id}", params: { include: "room_users" }, headers: auth_headers

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)

      # Should limit to default of 10 room_users
      expect(json_response["room_users"].length).to eq(10)
    end

    it "respects custom association limits" do
      # Create many room_users for the operation room
      create_list(:room_user, 15, operation_room: operation_room)

      get "/api/v1/operation_rooms/#{operation_room.id}", params: { include: "room_users", room_users_limit: 5 }, headers: auth_headers

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)

      # Should limit to specified 5 room_users
      expect(json_response["room_users"].length).to eq(5)
    end

    it "handles invalid includes gracefully" do
      get "/api/v1/operation_rooms/#{operation_room.id}", params: { include: "invalid_association" }, headers: auth_headers

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)

      # Should return data without includes
      expect(json_response).not_to have_key("invalid_association")
    end
  end
end
