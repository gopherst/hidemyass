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

  HTTP_ERRORS = [
    Timeout::Error,
    Errno::EINVAL,
    Errno::ECONNRESET,
    Errno::ECONNREFUSED,
    Errno::ETIMEDOUT,
    EOFError,
    Net::HTTPBadResponse,
    Net::HTTPHeaderSyntaxError,
    Net::ProtocolError
  ]

  def self.options
    @options ||= {
      :log   => true,
      :local => false,
      :clear_cache => false
    }
  end

  # Clears cached proxies.
  def self.clear_cache
    @proxies = nil
  end

  # Returns HMA proxies.
  def self.proxies
    clear_cache if options[:clear_cache]

    @proxies ||= begin
      html = get_hma_body

      html.xpath('//table[@id="listtable"]/tr').collect do |node|
        ip = HideMyAss::IP.new(node.at_xpath('td[2]/span'))
        next unless ip.valid?
        {
          host: ip.address,
          port: node.at_xpath('td[3]').content.strip
        }
      end
    end
  end

  # Sets form data to support custom searches.
  def self.form_data=(data)
    @form_data = data if data
  end

  # Set form data for HMA search
  #
  # c[]  - Countries
  # p    - Port. Defaults to all ports.
  # pr[] - Protocol. 0..2 = HTTP, HTTPS, socks4/5
  # a[]  - Anonymity level. 0..4 = None, Low, Medium, High, High +KA
  # sp[] - Speed. 0..2 = Slow, Medium, Fast.
  # ct[] - Connection time. 0..2 = Slow, Medium, Fast
  # s    - Sort. 0..3 = Response time, Connection time, Country A-Z.
  # o    - Order. 0, 1 = DESC, ASC.
  # pp   - Per Page. 0..3 = 10, 25, 50, 100.
  # sortBy - Sort by. Defaults to date.
  #
  # Returns form data hash.
  def self.form_data
    @form_data ||= {
      "c[]"  => ["Brazil", "Mexico", "United States"],
      "p"    => nil,
      "pr[]" => [0,1],
      "a[]"  => [0,1,2,3],
      "sp[]" => [2,3],
      "ct[]" => [2,3],
      "s"    => 0,
      "o"    => 0,
      "pp"   => 2,
      "sortBy" => "date"
    }
  end

  private

  # Returns HMA body as a Nokogiri HTML Document.
  def self.get_hma_body
    res = Net::HTTP.post_form(URI(ENDPOINT), form_data)

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