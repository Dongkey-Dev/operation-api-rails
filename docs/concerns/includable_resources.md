# IncludableResources Concern

## Overview

The `IncludableResources` concern provides a standardized way to handle the inclusion of associated resources in API responses with support for limiting the number of included records per association. It integrates with Pagy for pagination and supports both collection endpoints (`index`) and single resource endpoints (`show`).

## Features

- Configuration of allowed includes and default limits per association
- Parsing and validating includes from query parameters
- Applying includes and eager loading to ActiveRecord queries
- Applying limits to included associations after eager loading
- Preparing include options for JSON serialization
- Handling pagination with Pagy for collections
- Error handling for pagination edge cases

## Installation

1. Include the concern in your controller:

```ruby
class YourController < ApplicationController
  include Pagy::Backend
  include IncludableResources
  
  # Configure allowed includes and their default limits
  configure_includes do |config|
    config.allowed_includes = %w[association1 association2 association3]
    config.default_limits = { association1: 10, association2: 5 }
  end
  
  # Your controller actions...
end
```

## Usage

### Collection Endpoint (index)

```ruby
def index
  base_query = YourModel.all
  # Apply any filters, scopes, or authorization
  base_query = policy_scope(apply_scopes(base_query))
  
  # Apply sorting if needed
  if params[:sort_by].present?
    base_query = base_query.order(params[:sort_by] => params[:sort_direction] || :asc)
  end
  
  # Apply pagination and includes with limits
  result = with_includes_and_pagination(
    base_query,
    items_per_page: params[:limit] || 15,
    page_number: params[:page] || 1
  )
  
  render json: {
    data: result[:records].as_json(include: result[:include_options]),
    meta: {
      pagination: result[:pagination]
    }
  }
end
```

### Single Resource Endpoint (show)

```ruby
def show
  @record = YourModel.find(params[:id])
  authorize @record if respond_to?(:authorize)
  
  # Apply includes with limits
  result = with_includes_for_record(@record)
  
  render json: result[:record].as_json(include: result[:include_options])
end
```

## API Parameters

### Include Parameter

To include associated resources, use the `include` query parameter with a comma-separated list of associations:

```
GET /api/v1/resources?include=association1,association2
```

Only associations that are in the `allowed_includes` configuration will be included.

### Association Limit Parameters

To limit the number of records for a specific association, use the `{association_name}_limit` parameter:

```
GET /api/v1/resources?include=association1&association1_limit=5
```

If no limit is specified, the default limit from the configuration will be used.

## Pagination

The concern integrates with Pagy for pagination. Use the following parameters:

- `page`: The page number to retrieve (default: 1)
- `limit`: The number of records per page (default: 15)

The pagination metadata in the response includes:

```json
{
  "meta": {
    "pagination": {
      "per_page": 15,
      "current_page": 1,
      "total_pages": 5,
      "total_count": 75,
      "next_page": 2
    }
  }
}
```

## Error Handling

### Pagination Overflow

If a page number is requested that is beyond the available pages, the concern will return an empty array with appropriate pagination metadata.

### Invalid Includes

If an invalid association is requested in the `include` parameter, it will be ignored and only valid associations will be included.

## Implementation Details

### How Association Limits Work

Association limits are applied after eager loading the associations. This is because Rails does not support limiting associations during the `includes` call in a way that works consistently across different association types.

The concern modifies the loaded association collections in memory after they are loaded, which ensures that the limits are applied correctly regardless of the association type.

### Performance Considerations

- Use appropriate database indexes for columns used in filtering and sorting
- Consider using `pagy_countless` for large datasets where counting is expensive
- For very large associations, consider implementing custom pagination for the associations themselves

## Testing

See the `spec/concerns/includable_resources_spec.rb` and `spec/requests/api/v1/operation_rooms_spec.rb` files for examples of how to test controllers that use this concern.
