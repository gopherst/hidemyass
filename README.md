# HIDE MY ASS! [![Build Status](https://travis-ci.org/jassa/hidemyass.png)](https://travis-ci.org/jassa/hidemyass)

Hide My Ass! fetches and connects to proxies at www.hidemyass.com.

This ruby gem aims to connect you anonymously, it fetches proxies from hidemyass.com and tries each one until a successful connection is made.

## Installation

Add this line to your application's Gemfile:

    gem 'hidemyass'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hidemyass

## Usage

    HideMyAss.options[:max_concurrency] = 3
    response = HideMyAss::Request.get("www.google.com", timeout: 2)
    => #<Typhoeus::Response @options={:return_code=>:ok ...>

`HideMyAss::Request.get` will try successive proxies until one returns an HTTP
code between 200 and 300.

If you want more control, you can retrieve the proxies list and connect manually

    HideMyAss.proxies.each do |proxy|
      request = Typhoeus::Request.post(base_url, options)
      request.on_complete do |response|
        if # some success condition...
          @response = response
          HideMyAss.hydra.abort
        end
      end
    end

    @response # holds successful response

To clear the cached proxies on every request (disabled by default):

    HideMyAss.options[:clear_cache] = true

or simply run:

    HideMyAss.clear_cache

## Roadmap

* Hijack HTTP requests automatically
* Get proxies other page numbers (currently 50 results only)
* Improve tests suite
* Clean code and refactor

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`), and make sure to include specs
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
