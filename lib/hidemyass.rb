require 'nokogiri'
require 'open-uri'
require 'net/http'

require 'hidemyass/version'
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