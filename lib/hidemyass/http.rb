# TODO: Hijack HTTP calls automatically

module HideMyAss
  module HTTP

    def HTTP.start(address, *arg, &block)
      HideMyAss.log 'Connecting to ' + address + ' through:'
      response = nil

      if HideMyAss.options[:local]
        begin
          HideMyAss.log 'localhost...'
          response = Net::HTTP.start(address, *arg, &block)

          HideMyAss.log response.class.to_s

          if response.class.ancestors.include?(Net::HTTPSuccess)
            return response
          end
        rescue *HTTP_ERRORS => error
          HideMyAss.log error
        end
      end

      HideMyAss.proxies.each do |proxy|
        begin
          HideMyAss.log proxy[:host] + ':' + proxy[:port]
          response = Net::HTTP::Proxy(proxy[:host],
            proxy[:port]).start(address, *arg, &block)

          HideMyAss.log response.class.to_s

          if response.class.ancestors.include?(Net::HTTPSuccess)
            return response
          end
        rescue *HTTP_ERRORS => error
          HideMyAss.log error
        end
      end

      response
    end
  end
end
