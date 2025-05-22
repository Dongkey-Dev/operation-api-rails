#!/usr/bin/env ruby

require 'fileutils'

# Helper methods to replace Rails methods
def singularize(word)
  # Simple singularization rules
  if word.end_with?('ies')
    return word[0...-3] + 'y'
  elsif word.end_with?('es')
    return word[0...-2]
  elsif word.end_with?('s')
    return word[0...-1]
  end
  word
end

def camelize(word)
  # Simple camelization
  word.split('_').map(&:capitalize).join
end

# List of controllers to update
controllers = [
  'chat_messages',
  'command_responses',
  'commands',
  'customer_admin_rooms',
  'customers',
  'features',
  'operation_rooms',
  'plans',
  'room_features',
  'room_plan_histories',
  'room_user_events',
  'room_user_nickname_histories',
  'room_users'
]

# Base directory
controller_dir = File.join(Dir.pwd, 'app', 'controllers', 'api', 'v1')
backup_dir = File.join(Dir.pwd, 'app', 'controllers', 'backup')

# Ensure backup directory exists
FileUtils.mkdir_p(backup_dir) unless Dir.exist?(backup_dir)

# Process each controller
controllers.each do |controller|
  controller_file = File.join(controller_dir, "#{controller}_controller.rb")
  backup_file = File.join(backup_dir, "#{controller}_controller.rb")
  
  if File.exist?(controller_file)
    # Create backup
    FileUtils.cp(controller_file, backup_file)
    
    # Read the file content with UTF-8 encoding
    content = File.read(controller_file, encoding: 'UTF-8')
    
    # Replace references to Api::V1::ModelName with just ModelName
    # This handles both singular and plural forms
    singular = singularize(controller)
    class_name = camelize(singular)
    
    # Replace Api::V1::ClassName with just ClassName
    new_content = content.gsub(/Api::V1::#{class_name}/, class_name)
    
    # Write the modified content back to the file with UTF-8 encoding
    File.write(controller_file, new_content, encoding: 'UTF-8')
    
    puts "Updated: #{controller}_controller.rb"
  else
    puts "Warning: #{controller_file} does not exist"
  end
end

puts "\nAll controllers have been updated and backups saved to app/controllers/backup/"
puts "Remember to check for any other references to Api::V1:: in your code."
