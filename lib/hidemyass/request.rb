require 'hidemyass/request/actions'

module HideMyAss

  # TODO: Hijack HTTP calls automatically
  class Request
    extend Request::Actions

    attr_accessor :response

    # Create a new request,
    # and run it through proxies until success.
    #
    # Example:
    # HideMyAss.get("www.google.com")
    # INFO -- : ** [hidemyass] Connecting to 127.0.0.1 through: 1.2.3.4:8080
    # INFO -- : ** [hidemyass] Connecting to 127.0.0.1 through: 2.3.4.5:8080
    # INFO -- : ** [hidemyass] Connecting to 127.0.0.1 through: 3.4.5.6:9090
    #
    # Returns Typhoeus::Response instance
    def initialize(base_url, options = {})
      @response = nil

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
      return @response
    end

  end # Request
end # HideMyAss