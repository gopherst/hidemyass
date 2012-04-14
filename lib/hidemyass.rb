require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'net/http'

require "hidemyass/version"

module Hidemyass

  HOST = 'hidemyass.com'
  LOG_PREFIX = "** [hidemyass] "

  HTTP_ERRORS = [Timeout::Error,
                 Errno::EINVAL,
                 Errno::ECONNRESET,
                 EOFError,
                 Net::HTTPBadResponse,
                 Net::HTTPHeaderSyntaxError,
                 Net::ProtocolError]

  class << self
    attr_reader :host, :port, :first_without_proxy, :proxies

    def initialize(host = nil, port = nil, first_without_proxy = false, &block)
      @host = host
      @port = port
      @first_without_proxy = first_without_proxy
    end

    def proxies
      uri = URI.parse('http://%s/proxy-list/search-225729' % HOST)
      dom = Nokogiri::HTML(open(uri))

      @proxies ||= dom.xpath('//table[@id="listtable"]/tr').collect do |node|
        { port: node.at_xpath('td[3]').content.strip,
          host: node.at_xpath('td[2]/span').xpath('text() | *[not(contains(@style,"display:none"))]').
                  map(&:content).compact.join.to_s }
    end

    def request(host = @host, port = @port, first_without_proxy = @first_without_proxy)
      return unless host && port

      response = nil
      if first_without_proxy
        begin
          response = Net::HTTP.start(host, port, &block)
        rescue *HTTP_ERRORS => error
          log :error, error
        end
      end

      proxies.each do |proxy|
        begin
          response = Net::HTTP::Proxy(proxy[:host], proxy[:port]).start(host, port, &block)
          break if response == Net::HTTPSuccess
        rescue *HTTP_ERRORS => error
          log :error, error
        end
      end

      response
    end

    def logger
      if defined?(Rails.logger)
        Rails.logger
      elsif defined?(RAILS_DEFAULT_LOGGER)
        RAILS_DEFAULT_LOGGER
      end
    end

    def log(level, message, response = nil)
      logger.send level, LOG_PREFIX + message if logger
    end
  end
end