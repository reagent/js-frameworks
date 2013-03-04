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

  post '/users' do
    halt 403 unless json_request?

    headers = {'Content-Type' => json_content_type}

    user = User.new(JSON.parse(request.body.read))

    if user.save
      [201, headers, user.to_json]
    else
      [400, headers, {:errors => user.errors.values.flatten}.to_json]
    end
  end

  private

  def request_content_type
    request.env['CONTENT_TYPE'] || request.env['HTTP_ACCEPT']
  end

  def json_content_type
    'application/json'
  end

  def json_request?
    request_content_type == json_content_type
  end

end