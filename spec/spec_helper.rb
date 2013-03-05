require 'rubygems'
require 'bundler'

Bundler.setup(:default, :test)

require 'data_mapper'
require 'sinatra'
require 'rspec'
require 'rack/test'

root = File.expand_path(File.dirname(__FILE__) + '../..')

$:.unshift("#{root}/app")

require 'config/boot'
require 'app'

require 'factories'

Dir["#{root}/spec/support/**/*.rb"].each {|f| require f }

RSpec.configure do |config|
  # reset database before each example is run
  config.before(:each) { DataMapper.auto_migrate! }
  config.include IntegrationSpecHelper, :type => :integration
end