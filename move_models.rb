#!/usr/bin/env ruby

require 'fileutils'

# List of models to move
models = [
  'chat_message',
  'command_response',
  'command',
  'customer_admin_room',
  'customer',
  'feature',
  'operation_room',
  'plan',
  'room_feature',
  'room_plan_history',
  'room_user_event',
  'room_user_nickname_history',
  'room_user'
]

# Base directories
src_dir = File.join(Dir.pwd, 'app', 'models', 'api', 'v1')
dest_dir = File.join(Dir.pwd, 'app', 'models')
backup_dir = File.join(Dir.pwd, 'app', 'models', 'backup')

# Ensure backup directory exists
FileUtils.mkdir_p(backup_dir) unless Dir.exist?(backup_dir)

# Process each model
models.each do |model|
  src_file = File.join(src_dir, "#{model}.rb")
  dest_file = File.join(dest_dir, "#{model}.rb")
  backup_file = File.join(backup_dir, "#{model}.rb")
  
  if File.exist?(src_file)
    # Create backup
    FileUtils.cp(src_file, backup_file)
    
    # Read the file content
    content = File.read(src_file)
    
    # Replace the namespaced class definition with a simple one
    new_content = content.gsub(/class Api::V1::([A-Za-z0-9_]+)/, 'class \1')
    
    # Write the modified content to the destination
    File.write(dest_file, new_content)
    
    # Remove the original file
    FileUtils.rm(src_file)
    
    puts "Moved and updated: #{model}.rb"
  else
    puts "Warning: #{src_file} does not exist"
  end
end

puts "\nAll models have been moved to app/models/ and backups saved to app/models/backup/"
puts "Remember to update your routes and any references to these models in your code."
