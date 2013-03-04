require 'rubygems'
require 'bundler'
require 'bundler/setup'

require 'sinatra/base'

$:.unshift(File.dirname(__FILE__))

require 'config/boot'

class App < Sinatra::Base
  get '/' do
    erb :index
  end
end
