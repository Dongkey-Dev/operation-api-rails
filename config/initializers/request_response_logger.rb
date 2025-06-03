# frozen_string_literal: true

# Middleware to log all incoming requests and outgoing responses
class RequestResponseLogger
  def initialize(app)
    @app = app
  end

  def call(env)
    # Start timing
    start_time = Time.now

    # Create a request object
    request = ActionDispatch::Request.new(env)

    # Log the request with a more visible format
    log_request(request)

    # Process the request
    status, headers, response = @app.call(env)

    # Calculate request duration
    duration = Time.now - start_time

    # Log the response with a more visible format
    log_response(status, headers, response, duration)

    # Return the response
    [ status, headers, response ]
  end

  private

  def log_request(request)
    begin
      # Only show sensitive headers like authorization headers
      sensitive_headers = show_sensitive_headers(request.headers)

      # Format request parameters, filtering sensitive data
      params = request.filtered_parameters.to_json rescue "Unable to parse parameters"

      # Create a more visible log entry with separators
      Rails.logger.info("
==================== REQUEST START ====================
")
      Rails.logger.info("[REQUEST] #{request.request_method} #{request.fullpath}")
      Rails.logger.info("[REQUEST HEADERS] #{sensitive_headers}")
      Rails.logger.info("[REQUEST PARAMS] #{params}")
      Rails.logger.info("==================== REQUEST END ====================
")
    rescue => e
      # Log any errors that occur during request logging
      Rails.logger.error("Error logging request: #{e.message}
#{e.backtrace.join("\n")}")
    end
  end

  def log_response(status, headers, response, duration)
    begin
      # Only show sensitive headers in response
      sensitive_headers = show_sensitive_headers(headers || {})

      # Get response body, but handle streaming responses
      body = ""

      # Make a safe copy of the response body
      if response.is_a?(Array)
        response_body = response.dup

        # Join all response fragments
        response_body.each do |fragment|
          body << fragment.to_s if fragment.respond_to?(:to_s)
        end
      elsif response.respond_to?(:body) && response.body.respond_to?(:to_s)
        # Handle ActionDispatch::Response objects
        body = response.body.to_s
      end

      # Try to parse JSON for better formatting if it's a JSON response
      if headers && headers["Content-Type"] && headers["Content-Type"].include?("application/json")
        begin
          parsed_json = JSON.parse(body)
          body = JSON.pretty_generate(parsed_json)
        rescue JSON::ParserError
          # If parsing fails, use the original body
        end
      end

      # Don't log the entire response body if it's too large
      if body.length > 1000
        body = body[0..1000] + "... (truncated)"
      end

      # Create a more visible log entry with separators
      Rails.logger.info("
==================== RESPONSE START ====================
")
      Rails.logger.info("[RESPONSE] Status: #{status} | Duration: #{duration.round(2)}s")
      Rails.logger.info("[RESPONSE HEADERS] #{sensitive_headers}")
      Rails.logger.info("[RESPONSE BODY] #{body}")
      Rails.logger.info("==================== RESPONSE END ====================
")
    rescue => e
      # Log any errors that occur during response logging
      Rails.logger.error("Error logging response: #{e.message}
#{e.backtrace.join("\n")}")
    end
  end

  def show_sensitive_headers(headers)
    sensitive = {}

    # Filter only HTTP headers with sensitive information
    headers.each do |key, value|
      # Convert header names to strings
      header_name = key.to_s
      
      # Only include HTTP headers (which typically start with HTTP_)
      # and only those that contain sensitive information
      if header_name.start_with?("HTTP_") && 
         (header_name.downcase.include?("authorization") ||
          header_name.downcase.include?("cookie") ||
          header_name.downcase.include?("token"))
        sensitive[header_name] = value
      end
    end

    sensitive
  rescue => e
    # Return empty hash if we can't process headers
    Rails.logger.error("Error processing sensitive headers: #{e.message}")
    {}
  end
end

# Add the middleware to the Rails application
Rails.application.config.middleware.use RequestResponseLogger
