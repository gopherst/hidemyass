require 'hidemyass'

module Hidemyass
  require 'rails'
  
  class Railtie
    def self.insert
      Hidemyass.options[:logger] = Rails.logger if defined?(Rails)
      Hidemyass.options[:logger] = ActiveRecord::Base.logger if defined?(ActiveRecord)
    end
  end
end