ENV['RAILS_ENV'] ||= 'production'

RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.gem "RedCloth"
   
  config.time_zone = 'UTC'
end