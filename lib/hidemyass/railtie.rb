require 'hidemyass'

module HideMyAss
  require 'rails'
  
  class Railtie < Rails::Railtie
    initializer "hidemyass.configure_rails_initialization" do
      HideMyAss.options[:logger] = Rails.logger if defined?(Rails)
      HideMyAss.options[:logger] = ActiveRecord::Base.logger if defined?(ActiveRecord)
    end
  end
end