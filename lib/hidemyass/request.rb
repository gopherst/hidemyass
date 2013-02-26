# TODO: Hijack HTTP calls automatically

module HideMyAss

  # Pass request messages to Typhoeus.
  module Request

    # Make a get request.
    #
    # Example (timeout in seconds):
    # HideMyAss.get("www.example.com", timeout: 3)
    #
    # Returns Typhoeus::Response instance.
    def self.get(base_url, options = {})
      options.merge!(:method => :get)
      @response = nil

      HideMyAss.log "Connecting to #{base_url} through:"
      HideMyAss.proxies.compact.each do |proxy|
        options[:proxy] = "http://#{proxy[:host]}:#{proxy[:port]}"

        request = Typhoeus::Request.new(base_url, options)
        request.on_complete do |response|
          HideMyAss.log options[:proxy]

          if (200..300).member?(response.code)
            @response = response and HideMyAss.hydra.abort
          end
        end

        HideMyAss.hydra.queue(request)
      end

      HideMyAss.hydra.run
      return @response
    end

  end # Request
end # HideMyAss