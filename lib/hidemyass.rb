require 'nokogiri'
require 'open-uri'
require 'net/http'

require 'hidemyass/version'
require 'hidemyass/logger'
require 'hidemyass/http'

module Hidemyass

  HOST = 'hidemyass.com'
  LOG_PREFIX = '** [hidemyass] '

  HTTP_ERRORS = [Timeout::Error,
                 Errno::EINVAL,
                 Errno::ECONNRESET,
                 EOFError,
                 Net::HTTPBadResponse,
                 Net::HTTPHeaderSyntaxError,
                 Net::ProtocolError]

  class << self
    def proxies
      uri = URI.parse('http://%s/proxy-list/search-225729' % HOST)
      dom = Nokogiri::HTML(open(uri))

      @proxies ||= dom.xpath('//table[@id="listtable"]/tr').collect do |node|
        { port: node.at_xpath('td[3]').content.strip,
          host: node.at_xpath('td[2]/span').xpath('text() | *[not(contains(@style,"display:none"))]').
                  map(&:content).compact.join.to_s }
      end
    end
  end
end