require 'open-uri'
require 'net/http'
require 'nokogiri'

require 'hidemyass/version'
require 'hidemyass/ip'
require 'hidemyass/http'
require 'hidemyass/logger'
require 'hidemyass/railtie' if defined?(Rails)

module HideMyAss
  extend Logger

  SITE     = "http://hidemyass.com".freeze
  ENDPOINT = "http://hidemyass.com/proxy-list/".freeze

  LOG_PREFIX = '** [hidemyass] '
  
  HTTP_ERRORS = [Timeout::Error,
                 Errno::EINVAL,
                 Errno::ECONNRESET,
                 Errno::ECONNREFUSED,
                 Errno::ETIMEDOUT,
                 EOFError,
                 Net::HTTPBadResponse,
                 Net::HTTPHeaderSyntaxError,
                 Net::ProtocolError]
                 
   def self.options
     @options ||= {
       :log => true,
       :local => false,
       :clear_cache => false
     }
   end

  def self.proxies
    clear_cache if options[:clear_cache]

    unless @proxies
      html = get_hma_body
    end

    @proxies ||= html.xpath('//table[@id="listtable"]/tr').collect do |node|
      ip = HideMyAss::IP.new(node.at_xpath('td[2]/span'))
      next unless ip.valid?
      { 
        host: ip.address,
        port: node.at_xpath('td[3]').content.strip
      }
    end
  end
  
  def self.clear_cache
    @proxies = nil
  end

  private

  def self.get_hma_body
    data = {
      "c[]"  => ["United States"],
      "p"    => nil,
      "pr[]" => [0,1,2],
      "a[]"  => [0,1,2,3],
      "sp[]" => [2,3],
      "ct[]" => [2,3],
      "s"    => 0,
      "o"    => 0,
      "pp"   => 2,
      "sortBy" => "date"
    }

    res  = Net::HTTP.post_form(URI(ENDPOINT), data)

    body = case res
    when Net::HTTPSuccess then
      res.body
    when Net::HTTPRedirection then
      Net::HTTP.get_response(URI(SITE + res['location'])).body
    else
      res.value
    end

    return Nokogiri::HTML(body)
  end
end