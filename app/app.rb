require 'rubygems'
require 'bundler/setup'

require 'sinatra/base'

$:.unshift(File.dirname(__FILE__))

require 'config/boot'

class App < Sinatra::Base
  before %r{^(?!/$)} do
    halt api_send_response(406) unless json_request?
  end

  get '/' do
    erb :index
  end

  get '/articles' do
    api_send_success_response(Article.all)
  end

  post '/articles' do
    return not_authorized unless logged_in?

    article = Article.new(parsed_attributes.merge(:user => current_user))

    if article.save
      api_send_success_response(article)
    else
      api_send_error_response(article)
    end
  end

  get '/articles/:id' do
    article = Article.get(params[:id])
    if article
      api_send_success_response(article)
    else
      not_found
    end
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

  def logged_in?
    !current_user.nil?
  end

  def current_user
    if !instance_variable_defined?(:@current_user)
      @current_user = user_from_token
    end
    @current_user
  end

  def user_from_token
    token = Token.get(current_user_token)
    token ? token.user : nil
  end

  def current_user_token
    request.env['HTTP_X_USER_TOKEN']
  end

  def not_found
    api_send_response(404)
  end

  def not_authorized
    api_send_response(401, {'errors' => ['Authentication is required']})
  end

  def api_send_success_response(object, status_code = 200)
    api_send_response(status_code, object)
  end

  def api_send_error_response(object, status_code = 400)
    api_send_response(status_code, {:errors => object.errors.values.flatten})
  end

  def api_send_response(status_code, data_to_send = nil)
    body = data_to_send ? data_to_send.to_json : ''
    [status_code, response_headers, body]
  end

  def json_content_type
    'application/json'
  end

  def response_headers
    {'Content-Type' => json_content_type}
  end

  def parsed_attributes
    JSON.parse(request.body.read)
  end

  def request_content_type
    request.env.values_at('CONTENT_TYPE', 'HTTP_ACCEPT').first
  end

  def json_request?
    request_content_type == json_content_type
  end

end