require 'rubygems'
require 'bundler'

Bundler.setup(:default, :test)

require 'data_mapper'
require 'sinatra'
require 'rspec'
require 'rack/test'

$:.unshift(File.expand_path(File.dirname(__FILE__) + '../../app'))

require 'config/boot'
require 'app'

require 'factories'

RSpec.configure do |config|
  # reset database before each example is run
  config.before(:each) { DataMapper.auto_migrate! }
end