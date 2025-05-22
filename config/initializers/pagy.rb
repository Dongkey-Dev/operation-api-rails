# Configure Pagy for API usage
require 'pagy'
require 'pagy/extras/overflow'
require 'pagy/extras/metadata'

# Default items per page for each model
PAGY_ITEMS = {
  'Customer' => 20,
  'OperationRoom' => 15,
  'Command' => 25,
  'ChatMessage' => 50,
  'RoomUser' => 20
}.freeze

# Configure Pagy defaults
Pagy::DEFAULT.merge!(
  items: 20,        # Default items per page
  outset: 0,        # Starting page number
  overflow: :last_page,  # Handle overflow by showing the last page
  metadata: [:page, :items, :pages, :count, :prev, :next]  # Include metadata in response
)
