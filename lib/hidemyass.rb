require 'nokogiri'
require 'typhoeus'

require 'hidemyass/version'
require 'hidemyass/logger'
require 'hidemyass/ip'
require 'hidemyass/request'
require 'hidemyass/railtie' if defined?(Rails)

module HideMyAss
  extend self
  extend Logger
  extend Request::Actions

  SITE     = "http://hidemyass.com".freeze
  ENDPOINT = "http://hidemyass.com/proxy-list/".freeze

  LOG_PREFIX = "** [hidemyass]"

  def options
    @options ||= {
      :log   => true,
      :local => false,
      :clear_cache => false,
      :max_concurrency => 10
    }
  end

  # Hydra will handle how many requests you can
  # make in parallel.
  #
  # Typhoeus built-in limit is 200,
  # but this depends heavily on your implementation.
  # If you want to return as soon as you get a successful response,
  # you should set a much, much lower limit, e.g. 10
  def hydra
    @hydra ||= begin
      opts = if options[:max_concurrency]
        { :max_concurrency => options[:max_concurrency] }
      end

      Typhoeus::Hydra.new(opts || {})
    end
  end

  # Clears cached proxies.
  def clear_cache
    @proxies = nil
  end

  # Returns HMA proxies.
  def proxies
    clear_cache if options[:clear_cache]

    @proxies ||= begin
      html = get_hma_body

      html.xpath('//table[@id="listable"]/tbody/tr').collect do |node|
        ip = HideMyAss::IP.new(node.at_xpath('td[2]/span'))
        next unless ip.valid?
        {
          host: ip.address,
          port: node.at_xpath('td[3]').content.strip
        }
      end.compact
    end
  end

  # Sets form data to support custom searches.
  def form_data=(data)
    @form_data = data if data
  end

  # Form data for HMA search
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
  def form_data
    @form_data ||= {
      "c"  => ["Brazil", "Mexico", "United States"],
      "p"  => nil,
      "pr" => [0],
      "a"  => [0,1,2,3],
      "sp" => [2,3],
      "ct" => [2,3],
      "s"  => 0,
      "o"  => 0,
      "pp" => 2,
      "sortBy" => "date"
    }
  end

  private

  # Returns HMA body as a Nokogiri HTML Document.
  def get_hma_body
    res = Typhoeus.post(ENDPOINT, body: form_data,
      followlocation: true)

    return Nokogiri::HTML(res.body)
  end
end