module OperationRoomsIncludable
  extend ActiveSupport::Concern

  # Process include parameters to handle associations
  def process_include_params
    return [] unless params[:include].present?

    # Split the include parameter by comma and convert to symbols
    requested_includes = params[:include].split(",").map(&:strip).map(&:to_sym)

    # Define allowed associations to include
    allowed_associations = [:commands, :customer_admin_rooms, :admin_rooms, :room_users, :operation_rooms]

    # Filter to only allowed associations
    requested_includes & allowed_associations
  end

  # Adds operation rooms to customer data
  def add_operation_rooms_to_customer(customer_data, customer)
    # Get member operation rooms through room_users
    member_rooms = OperationRoom.joins(:room_users)
                                .where(room_users: { user_id: customer.user_id })

    # Get admin operation rooms
    admin_rooms = OperationRoom.where(customer_admin_user_id: customer.id)

    # Combine both types of rooms, ensuring no duplicates
    combined_rooms = {}

    member_rooms.each do |room|
      combined_rooms[room.id] = room.as_json
    end

    admin_rooms.each do |room|
      combined_rooms[room.id] = room.as_json
    end

    # Add to customer data
    customer_data["operation_rooms"] = combined_rooms.values
    customer_data
  end

  # Adds operation rooms to multiple customers
  def add_operation_rooms_to_customers(customers_data, customers)
    # Get all customer IDs and user IDs for efficient querying
    customer_ids = customers.pluck(:id)
    user_ids = customers.pluck(:user_id)

    # Get all operation rooms where these customers are members or admins
    member_rooms = OperationRoom.joins(:room_users)
                                .where(room_users: { user_id: user_ids })
                                .select("operation_rooms.*, room_users.user_id")

    admin_rooms = OperationRoom.where(customer_admin_user_id: customer_ids)

    # Create lookup hashes for efficient assignment
    rooms_by_user_id = {}
    member_rooms.each do |room|
      rooms_by_user_id[room.user_id] ||= []
      rooms_by_user_id[room.user_id] << room.as_json
    end

    rooms_by_customer_id = {}
    admin_rooms.each do |room|
      rooms_by_customer_id[room.customer_admin_user_id] ||= []
      rooms_by_customer_id[room.customer_admin_user_id] << room.as_json
    end

    # Add operation_rooms to each customer
    customers_data.each do |customer|
      customer_id = customer["id"]
      user_id = customer["user_id"]

      # Combine member rooms and admin rooms, ensuring no duplicates
      member_room_list = rooms_by_user_id[user_id] || []
      admin_room_list = rooms_by_customer_id[customer_id] || []

      # Use a hash to deduplicate by ID
      combined_rooms = {}
      member_room_list.each { |room| combined_rooms[room["id"]] = room }
      admin_room_list.each { |room| combined_rooms[room["id"]] = room }

      customer["operation_rooms"] = combined_rooms.values
    end

    customers_data
  end

  # Prepare include options for as_json
  def prepare_include_options(includes)
    include_options = {}
    includes.each do |association|
      include_options[association] = {}
    end
    include_options
  end
end
