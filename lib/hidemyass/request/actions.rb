# TODO: Hijack HTTP calls automatically

module HideMyAss

  # Pass request messages to Typhoeus.
  class Request
    module Actions

      # Make a get request.
      #
      # Example:
      # HideMyAss.get("www.example.com")
      #
      # @options (See https://github.com/typhoeus/typhoeus)
      #
      # Returns Typhoeus::Response instance.
      def get(base_url, options = {})
        Request.new(base_url, options.merge!(:method => :get)).run
      end

      # Make a post request.
      #
      # Example:
      # HideMyAss.post("www.example.com")
      #
      # Returns Typhoeus::Response instance.
      def post(base_url, options = {})
        Request.new(base_url, options.merge!(:method => :post)).run
      end

      # Make a put request.
      #
      # Example:
      # HideMyAss.put("www.example.com/posts/1")
      #
      # Returns Typhoeus::Response instance.
      def put(base_url, options = {})
        Request.new(base_url, options.merge!(:method => :put)).run
      end

      # Make a delete request.
      #
      # Example:
      # HideMyAss.delete("www.example.com/posts/1")
      #
      # Returns Typhoeus::Response instance.
      def delete(base_url, options = {})
        Request.new(base_url, options.merge!(:method => :delete)).run
      end

    end # Actions
  end # Request
end # HideMyAss