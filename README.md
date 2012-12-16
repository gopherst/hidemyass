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

    @uri = URI('http://www.iana.org/domains/example/')
    @request = Net::HTTP::Get.new(@uri.request_uri)
    @request['Referer'] = @uri.host
    
    response = HideMyAss::HTTP.start(@uri.host, @uri.port) do |http|
      http.request(@request)
    end
    
    response
    => #<Net::HTTPOK 200 OK readbody=true>
    
This method defaults to return on HTTPSuccess (2xx)
If you want more control to follow redirections or whatever, you can retrieve the proxies list and connect manually

    HideMyAss.proxies.each do |proxy|
      response = Net::HTTP::Proxy(proxy[:host], proxy[:port]).start(@uri.host, @uri.port) do |http|
        http.request(@request)
      end
      if response.class.ancestors.include?(Net::HTTPRedirection)
        # ...
      end
    end
    
To try connecting through local machine before trying proxies:

    HideMyAss.options[:local] = true
    HideMyAss::HTTP.start ...
    
To clear the cached proxies on every request (disabled by default):

    HideMyAss.options[:clear_cache] = true
    
or simply run:

    HideMyAss.clear_cache
    
## Roadmap

* Improve the quality of returned proxies: currently I'm using the custom search url, but it seems to expire every n-days
* Get proxies from other pages
* Improve tests suite
* Clean code and refactor

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
