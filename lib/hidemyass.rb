require 'nokogiri'
require 'open-uri'
require 'net/http'
require 'logger'

require 'hidemyass/version'
require 'hidemyass/railtie'
require 'hidemyass/logger'
require 'hidemyass/http'

module Hidemyass
  extend Logger

  HOST = 'hidemyass.com'
  LOG_PREFIX = '** [hidemyass] '

  HTTP_ERRORS = [Timeout::Error,
                 Errno::EINVAL,
                 Errno::ECONNRESET,
                 EOFError,
                 Net::HTTPBadResponse,
                 Net::HTTPHeaderSyntaxError,
                 Net::ProtocolError]
                 
   def self.options
     @options ||= {
       :log => true
     }
   end

  def self.proxies
    uri = URI.parse('http://%s/proxy-list/search-225729' % HOST)
    dom = Nokogiri::HTML(open(uri))

    @proxies ||= dom.xpath('//table[@id="listtable"]/tr').collect do |node|
      { port: node.at_xpath('td[3]').content.strip,
        host: node.at_xpath('td[2]/span').xpath('text() | *[not(contains(@style,"display:none"))]').
                map(&:content).compact.join.to_s }
    end
  end
end