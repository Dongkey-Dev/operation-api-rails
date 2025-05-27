class Api::V1::RoomUsersController < ApplicationController
  include Pagy::Backend
  
  before_action :set_room_user, only: %i[ show update destroy ]

  # Define scopes that can be used for filtering
  has_scope :active, type: :boolean
  has_scope :inactive, type: :boolean
  has_scope :by_operation_room
  has_scope :by_user
  has_scope :by_role
  has_scope :joined_between
  has_scope :left_between
  has_scope :ordered_by_joined

  # GET /api/v1/room_users
  def index
    # Build base query with scopes
    base_query = apply_scopes(RoomUser)

    # Apply sorting if specified
    if params[:sortBy].present?
      sort_by = params[:sortBy]
      sort_order = params[:sortOrder]&.downcase == 'desc' ? :desc : :asc
      base_query = base_query.order(sort_by => sort_order)
    else
      # Default sorting using joined_at since there's no created_at in this table
      base_query = base_query.order(joined_at: :desc)
    end

    # Apply Pagy pagination
    items_per_page = params[:limit].present? ? params[:limit].to_i : 20
    page_number = params[:page].present? ? params[:page].to_i : 1
    
    begin
      @pagy, @room_users = pagy(base_query, items: items_per_page, page: page_number)
      
      # Determine if there's a next page
      has_next_page = @pagy.page < @pagy.pages
      next_page = has_next_page ? @pagy.page + 1 : nil
      
      # Render response with pagination metadata following our API standards
      render json: {
        data: @room_users,
        meta: {
          pagination: {
            per_page: items_per_page,
            current_page: @pagy.page,
            total_pages: @pagy.pages,
            total_count: @pagy.count,
            next_page: next_page
          }
        }
      }
    rescue Pagy::OverflowError
      # Handle the case where page is out of bounds
      render json: {
        data: [],
        meta: {
          pagination: {
            per_page: items_per_page,
            current_page: page_number,
            total_pages: 0,
            total_count: 0,
            next_page: nil
          }
        }
      }
    end
  end

  # GET /api/v1/room_users/1
  def show
    render json: @room_user
  end

  # GET /api/v1/room_users/by_room/:id
  def by_room
    operation_room_id = params[:id]
    
    # Find room users for the specified operation room
    base_query = RoomUser.where(operation_room_id: operation_room_id)
    
    # Apply sorting if specified
    if params[:sortBy].present?
      sort_by = params[:sortBy]
      sort_order = params[:sortOrder]&.downcase == 'desc' ? :desc : :asc
      base_query = base_query.order(sort_by => sort_order)
    else
      # Default sorting
      base_query = base_query.order(joined_at: :desc)
    end

    # Apply Pagy pagination
    items_per_page = params[:limit].present? ? params[:limit].to_i : 20
    page_number = params[:page].present? ? params[:page].to_i : 1
    
    begin
      @pagy, @room_users = pagy(base_query, items: items_per_page, page: page_number)
      
      # Determine if there's a next page
      has_next_page = @pagy.page < @pagy.pages
      next_page = has_next_page ? @pagy.page + 1 : nil
      
      # Render response with pagination metadata following our API standards
      render json: {
        data: @room_users,
        meta: {
          pagination: {
            per_page: items_per_page,
            current_page: @pagy.page,
            total_pages: @pagy.pages,
            total_count: @pagy.count,
            next_page: next_page
          }
        }
      }
    rescue Pagy::OverflowError
      # Handle the case where page is out of bounds
      render json: {
        data: [],
        meta: {
          pagination: {
            per_page: items_per_page,
            current_page: page_number,
            total_pages: 0,
            total_count: 0,
            next_page: nil
          }
        }
      }
    end
  end

  # GET /api/v1/room_users/by_user/:id
  def by_user
    user_id = params[:id]
    
    # Find room users for the specified user
    base_query = RoomUser.where(user_id: user_id)
    
    # Apply sorting if specified
    if params[:sortBy].present?
      sort_by = params[:sortBy]
      sort_order = params[:sortOrder]&.downcase == 'desc' ? :desc : :asc
      base_query = base_query.order(sort_by => sort_order)
    else
      # Default sorting
      base_query = base_query.order(joined_at: :desc)
    end

    # Apply Pagy pagination
    items_per_page = params[:limit].present? ? params[:limit].to_i : 20
    page_number = params[:page].present? ? params[:page].to_i : 1
    
    begin
      @pagy, @room_users = pagy(base_query, items: items_per_page, page: page_number)
      
      # Determine if there's a next page
      has_next_page = @pagy.page < @pagy.pages
      next_page = has_next_page ? @pagy.page + 1 : nil
      
      # Render response with pagination metadata following our API standards
      render json: {
        data: @room_users,
        meta: {
          pagination: {
            per_page: items_per_page,
            current_page: @pagy.page,
            total_pages: @pagy.pages,
            total_count: @pagy.count,
            next_page: next_page
          }
        }
      }
    rescue Pagy::OverflowError
      # Handle the case where page is out of bounds
      render json: {
        data: [],
        meta: {
          pagination: {
            per_page: items_per_page,
            current_page: page_number,
            total_pages: 0,
            total_count: 0,
            next_page: nil
          }
        }
      }
    end
  end

  # POST /api/v1/room_users
  def create
    @room_user = RoomUser.new(room_user_params)

    if @room_user.save
      render json: @room_user, status: :created, location: @room_user
    else
      render json: @room_user.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/room_users/1
  def update
    if @room_user.update(room_user_params)
      render json: @room_user
    else
      render json: @room_user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/room_users/1
  def destroy
    @room_user.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_room_user
      @room_user = RoomUser.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def room_user_params
      params.require(:room_user).permit(
        :operationRoomId, :userId, :nickname, :role, :joinedAt, :leftAt
      )
    end
end
