module Hidemyass
  module HTTP
    def HTTP.start(address, opts = { :try_local => false }, *arg, &block)
      Hidemyass.log 'Connecting to ' + address + ' from:'
      response = nil
  
      if opts[:try_local]
        begin
          Hidemyass.log 'localhost...'
          response = Net::HTTP.start(address, *arg, &block)
          Hidemyass.log response.class.to_s
          if response.class.ancestors.include?(Net::HTTPSuccess)
            return response
          end
        rescue *HTTP_ERRORS => error
          Hidemyass.log error
        end
      end
      
      Hidemyass.proxies.each do |proxy|
        begin
          Hidemyass.log proxy[:host] + ':' + proxy[:port]
          response = Net::HTTP::Proxy(proxy[:host], proxy[:port]).start(address, *arg, &block)
          Hidemyass.log response.class.to_s
          if response.class.ancestors.include?(Net::HTTPSuccess)
            return response
          end
        rescue *HTTP_ERRORS => error
          Hidemyass.log error
        end
      end

      response
    end
  end
end
