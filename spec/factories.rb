# This file is used by OAS Rails to generate example data for API documentation

FactoryBot.define do
  factory :chat_message do
    content { "Example message content" }
    operation_room_id { 1 }
    user_id { 1 }
    created_at { Time.current }
  end
end
