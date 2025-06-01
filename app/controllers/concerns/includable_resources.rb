module IncludableResources
  extend ActiveSupport::Concern

  # Configuration class method to set up allowed includes and their limits
  # Example usage in controller:
  # class Api::V1::OperationRoomsController < Api::ApiController
  #   include IncludableResources
  #
  #   configure_includes do |config|
  #     config.allowed_includes = %w[room_users customer_admin_room customer_admin_user features plans]
  #     config.default_limits = { room_users: 10 }
  #   end
  # end
  module ClassMethods
    def configure_includes
      config = IncludeConfiguration.new
      yield(config) if block_given?
      @include_configuration = config
    end

    def include_configuration
      @include_configuration || IncludeConfiguration.new
    end
  end

  # Class to hold configuration for includes
  class IncludeConfiguration
    attr_accessor :allowed_includes, :default_limits

    def initialize
      @allowed_includes = []
      @default_limits = {}
    end
  end

  # Parse and validate the include parameter
  def parse_includes
    return [] unless params[:include].present?

    includes = params[:include].to_s.split(',').map(&:strip).select(&:present?)
    allowed_includes = self.class.include_configuration.allowed_includes
    
    includes.select { |inc| allowed_includes.include?(inc) }
  end

  # Apply includes to a query
  def apply_includes(query)
    valid_includes = parse_includes
    query = query.includes(*valid_includes) if valid_includes.any?
    [query, valid_includes]
  end

  # Apply limits to included associations
  def apply_association_limits(records, valid_includes)
    return records if valid_includes.blank?

    # Handle different types of records
    if records.is_a?(ActiveRecord::Relation)
      # For ActiveRecord::Relation, we need to iterate through each record
      records.each do |record|
        apply_limits_to_record(record, valid_includes)
      end
    elsif records.is_a?(Array)
      # For arrays of records
      records.each do |record|
        apply_limits_to_record(record, valid_includes)
      end
    else
      # For a single record
      apply_limits_to_record(records, valid_includes)
    end
    
    # Return the original records (single record or collection)
    records
  end
  
  # Helper method to apply limits to a single record
  def apply_limits_to_record(record, valid_includes)
    return unless record.respond_to?(:association)
    
    valid_includes.each do |inc|
      association_name = inc.to_sym
      
      # Check if association is loaded and apply limit if needed
      if record.association(association_name).loaded?
        # Get limit for this association (from params or default)
        limit_param_name = "#{inc}_limit"
        limit = params[limit_param_name].present? ? params[limit_param_name].to_i : default_limit_for(inc)
        
        # Apply limit if one is set
        if limit.present? && limit > 0
          # Get the current association records and limit them
          association_records = record.send(association_name)
          record.send("#{association_name}=", association_records.first(limit))
        end
      end
    end
  end
  
  # Get the default limit for an association
  def default_limit_for(association_name)
    limits = self.class.include_configuration.default_limits
    limits[association_name.to_sym]
  end

  # Prepare include options for as_json
  def prepare_include_options(valid_includes)
    return nil unless valid_includes.any?
    
    include_options = {}
    valid_includes.each do |inc|
      include_options[inc.to_sym] = {}
    end
    
    include_options
  end

  # Apply includes to a collection and handle pagination
  def with_includes_and_pagination(base_query, items_per_page: 15, page_number: 1)
    # Apply includes
    base_query, valid_includes = apply_includes(base_query)
    
    # Apply pagination
    begin
      pagy, records = pagy(base_query, items: items_per_page, page: page_number)
      
      # Apply limits to associations
      records = apply_association_limits(records, valid_includes)
      
      # Prepare include options for rendering
      include_options = prepare_include_options(valid_includes)
      
      # Determine if there's a next page
      has_next_page = pagy.page < pagy.pages
      next_page = has_next_page ? pagy.page + 1 : nil
      
      # Return everything needed for rendering
      {
        records: records,
        include_options: include_options,
        pagination: {
          per_page: items_per_page,
          current_page: pagy.page,
          total_pages: pagy.pages,
          total_count: pagy.count,
          next_page: next_page
        },
        success: true
      }
    rescue Pagy::OverflowError
      # Handle the case where page is out of bounds
      {
        records: [],
        include_options: nil,
        pagination: {
          per_page: items_per_page,
          current_page: page_number,
          total_pages: 0,
          total_count: 0,
          next_page: nil
        },
        success: true
      }
    end
  end

  # Apply includes to a single record
  def with_includes_for_record(record)
    valid_includes = parse_includes
    
    # Reload the record with includes if needed
    if valid_includes.any?
      record_class = record.class
      record = record_class.includes(*valid_includes).find(record.id)
    end
    
    # Apply limits to associations
    record = apply_association_limits(record, valid_includes)
    
    # Prepare include options for rendering
    include_options = prepare_include_options(valid_includes)
    
    {
      record: record,
      include_options: include_options,
      success: true
    }
  end
end
