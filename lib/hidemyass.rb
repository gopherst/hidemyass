require 'nokogiri'
require 'open-uri'
require 'net/http'
require 'hidemyass/version'
require 'hidemyass/http'
require 'hidemyass/logger'
require 'hidemyass/railtie'
require 'logger'

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
       :log => true,
       :local => false
     }
   end

  def self.proxies
    uri = URI.parse('http://%s/proxy-list/search-291666' % HOST)
    dom = Nokogiri::HTML(open(uri))

    @proxies ||= dom.xpath('//table[@id="listtable"]/tr').collect do |node|
      ip = HideMyAss::IP.new(node.at_xpath('td[2]/span'))
      next unless ip.valid?
      { 
        port: node.at_xpath('td[3]').content.strip,
        host: ip.address
      }
    end
  end
end