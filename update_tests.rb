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

# Base directories
test_dir = File.join(Dir.pwd, 'test')
backup_dir = File.join(Dir.pwd, 'test', 'backup')

# Ensure backup directory exists
FileUtils.mkdir_p(backup_dir) unless Dir.exist?(backup_dir)

# Find all test files
test_files = Dir.glob(File.join(test_dir, '**', '*.rb'))

# Process each test file
test_files.each do |test_file|
  # Skip backup files
  next if test_file.include?('/backup/')
  
  # Create backup file path
  relative_path = test_file.sub(test_dir + '/', '')
  backup_file = File.join(backup_dir, File.basename(test_file))
  
  # Create backup
  FileUtils.cp(test_file, backup_file)
  
  # Read the file content with UTF-8 encoding
  content = File.read(test_file, encoding: 'UTF-8')
  
  # Replace class definitions
  new_content = content.gsub(/class Api::V1::([A-Za-z0-9_]+)/, 'class \1')
  
  # Replace model references in assertions
  new_content = new_content.gsub(/"Api::V1::([A-Za-z0-9_]+).count"/, '"\1.count"')
  
  # Write the modified content back to the file with UTF-8 encoding
  File.write(test_file, new_content, encoding: 'UTF-8')
  
  puts "Updated: #{relative_path}"
end

puts "\nAll test files have been updated and backups saved to test/backup/"
puts "Remember to check for any other references to Api::V1:: in your code."
