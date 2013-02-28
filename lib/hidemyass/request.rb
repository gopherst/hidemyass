require 'hidemyass/request/actions'
require 'hidemyass/request/operations'

module HideMyAss

  # TODO: Hijack HTTP calls automatically
  class Request
    extend  Request::Actions
    include Request::Operations

    # Returns the provided base url.
    attr_accessor :base_url

    # Returns options, which includes default parameters.
    attr_accessor :options

    # Returns the response.
    attr_accessor :response

    def initialize(base_url, options = {})
      self.base_url = base_url
      self.options  = options
      self.response = nil
    end
  end # Request
end # HideMyAss