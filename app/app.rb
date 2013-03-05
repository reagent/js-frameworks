require 'rubygems'
require 'bundler'
require 'bundler/setup'

require 'sinatra/base'

$:.unshift(File.dirname(__FILE__))

require 'config/boot'

class App < Sinatra::Base
  before %r{^(?!/$)} do
    halt 403 unless json_request?
  end

  get '/' do
    erb :index
  end

  post '/users' do
    user = User.new(parsed_attributes)

    if user.save
      api_send_success_response(user, 201)
    else
      api_send_error_response(user)
    end
  end

  post '/sessions' do
    session = Session.new(parsed_attributes)

    if session.authenticate
      api_send_success_response(session)
    else
      api_send_error_response(session)
    end
  end

  private

  def api_send_success_response(object, status_code = 200)
    api_send_response(status_code, object)
  end

  def api_send_error_response(object, status_code = 400)
    api_send_response(status_code, {:errors => object.errors.values.flatten})
  end

  def api_send_response(status_code, data_to_send)
    [status_code, {'Content-Type' => 'application/json'}, data_to_send.to_json]
  end

  def parsed_attributes
    JSON.parse(request.body.read)
  end

  def request_content_type
    request.env.values_at('CONTENT_TYPE', 'HTTP_ACCEPT').first
  end

  def json_content_type
    'application/json'
  end

  def json_request?
    request_content_type == json_content_type
  end

end