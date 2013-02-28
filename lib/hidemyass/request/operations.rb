module HideMyAss
  class Request

    module Operations

      # Run a request through the proxies.
      # Returns on successful http response.
      #
      # Example:
      # HideMyAss.get("www.google.com")
      #
      # Returns Typhoeus::Response instance
      def run
        HideMyAss.log "Connecting to #{base_url} through:"

        HideMyAss.proxies.each do |proxy|
          options[:proxy] = "http://#{proxy[:host]}:#{proxy[:port]}"

          # Pass request to Typhoeus
          request = Typhoeus::Request.new(base_url, options)
          request.on_complete do |response|
            HideMyAss.log "#{request.options[:proxy]} : #{response.code}"

            # Return on successful http code
            if (200..300).member?(response.code)
              @response = response and HideMyAss.hydra.abort
            end
          end

          # Queue parallel requests
          HideMyAss.hydra.queue(request)
        end

        HideMyAss.hydra.run

        # Return response saved on successful completion.
        @response
      end

    end # Operations
  end # Request
end # HideMyAss