require 'hidemyass'

module Hidemyass
  require 'rails'
  
  class Railtie < Rails::Railtie
    initializer "hidemyass.configure_rails_initialization" do
      Hidemyass.options[:logger] = Rails.logger if defined?(Rails)
      Hidemyass.options[:logger] = ActiveRecord::Base.logger if defined?(ActiveRecord)
    end
  end
end