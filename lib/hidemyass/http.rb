module Hidemyass
  class HTTP
    attr_reader :proxies, :response

    def start(address, opts = { :try_local => false }, *arg, &block)
      @response = nil
  
      if opts[:try_local]
        begin
          @response = Net::HTTP.start(address, *arg, &block)
          return if @response == Net::HTTPSuccess
        rescue *HTTP_ERRORS => error
          log :error, error
        end
      end

      proxies.each do |proxy|
        begin
          @response = Net::HTTP::Proxy(proxy[:host], proxy[:port]).start(*arg, &block)
          return if @response == Net::HTTPSuccess
        rescue *HTTP_ERRORS => error
          log :error, error
        end
      end

      @response
    end

    def proxies
      uri = URI.parse('http://%s/proxy-list/search-225729' % Hidemyass::HOST)
      dom = Nokogiri::HTML(open(uri))

      @proxies ||= dom.xpath('//table[@id="listtable"]/tr').collect do |node|
        { port: node.at_xpath('td[3]').content.strip,
          host: node.at_xpath('td[2]/span').xpath('text() | *[not(contains(@style,"display:none"))]').
                  map(&:content).compact.join.to_s }
      end
    end
  end
end