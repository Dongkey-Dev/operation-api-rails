# TokenCustomerFiltering Concern

## Overview
The TokenCustomerFiltering concern provides a standardized way to implement token-based customer filtering across API controllers. It automatically applies the `by_token_customer` scope to resource queries unless a `customer_id` parameter is explicitly provided, thereby reducing code duplication and ensuring consistent, secure filtering of resources by the authenticated customer token.

## Key Features
- **Centralized Filtering**: Automatically applies token-based customer filtering to specified resource classes
- **Configurable Resources**: Define which resource classes should have token-based filtering applied
- **Parameter Override**: Skip token-based filtering when a `customer_id` parameter is explicitly provided
- **Seamless Integration**: Works with existing scopes and pagination mechanisms
- **Reduced Duplication**: Eliminates the need for explicit filtering calls in each controller action

## Implementation Details
- Located at: `app/controllers/concerns/token_customer_filtering.rb`
- Controller configuration via class method: `filter_by_token_customer Resource1, Resource2, ...`
- Automatically applies to appropriate controller actions (index, active, by_command, active_by_command)
- Overrides the `apply_scopes` method to add token-based filtering

## Usage Example
```ruby
class Api::V1::CommandsController < Api::ApiController
  include Pagy::Backend
  include IncludableResources

  before_action :authenticate_user
  before_action :set_command, only: %i[show update destroy]
  
  # Configure token-based customer filtering for Command
  filter_by_token_customer Command

  # Define scopes that can be used for filtering
  has_scope :active, type: :boolean
  has_scope :inactive, type: :boolean
  has_scope :deleted, type: :boolean
  has_scope :by_customer, as: :customer_id
  
  def index
    # Token-based customer filtering is automatically applied by the TokenCustomerFiltering concern
    base_query = policy_scope(apply_scopes(Command))
    
    # Rest of the controller action...
  end
  
  # Other controller actions...
end
```

## Integration with Other Concerns
The TokenCustomerFiltering concern works seamlessly with other concerns like:
- **IncludableResources**: For handling API resource includes with limits
- **Pagy**: For offset-based pagination
- **CursorPagination**: For cursor-based pagination

## Model Requirements
Models that use token-based customer filtering should:
1. Include the `TokenScopable` concern or implement a compatible `by_token_customer` scope
2. Either have a `customer_id` column or implement a custom `by_token_customer` scope that joins to related tables

## Security Considerations
- Always ensure proper authentication before applying token-based filtering
- Verify that all controllers handling sensitive customer data use this concern
- Use Pundit policies in conjunction with token-based filtering for comprehensive authorization
- Regularly audit controllers to ensure consistent application of token-based filtering

## Testing Recommendations
- Test both with and without explicit `customer_id` parameters
- Verify that resources from other customers are not accessible
- Test edge cases like empty result sets and invalid customer tokens
- Include integration tests that verify the entire authentication and filtering flow
