require 'rubygems'
require 'bundler/setup'

require 'sinatra/base'

$:.unshift(File.dirname(__FILE__))

require 'config/boot'

class App < Sinatra::Base
  def self.api(verb, route, options = {}, &block)
    send(verb, route) do
      if !json_request?
        halt api_send_response(406)
      elsif options[:authenticate] && !logged_in?
        halt not_authorized
      else
        instance_eval(&block)
      end
    end
  end

  get '/' do
    erb :index
  end

  # Users
  api :post, '/users' do
    create_resource(User)
  end

  api :get, '/users/:id' do
    fetch_resource(User, params[:id])
  end

  api :get, '/account', :authenticate => true do
    api_send_success_response(current_user)
  end

  api :put, '/account', :authenticate => true do
    if current_user.update(parsed_attributes)
      api_send_success_response(current_user)
    else
      api_send_error_response(current_user, 422)
    end
  end

  api :delete, '/account', :authenticate => true do
    if current_user.destroy
      api_send_success_response(nil)
    else
      api_send_error_response(current_user, 422)
    end
  end

  # Authentication
  api :post, '/session' do
    session = Session.new(parsed_attributes)

    if session.authenticate
      api_send_success_response(session)
    else
      api_send_error_response(session)
    end
  end

  api :delete, '/session', :authenticate => true do
    current_user.token.destroy
    api_send_success_response(nil)
  end

  # Articles
  api :get, '/articles' do
    api_send_success_response(Article.all)
  end

  api :post, '/articles', :authenticate => true do
    create_resource(Article, :user => current_user)
  end

  api :get, '/articles/:id' do
    fetch_resource(Article, params[:id])
  end

  # Comments
  api :get, '/comments/:id' do
    fetch_resource(Comment, params[:id])
  end

  api :get, '/articles/:id/comments' do
    article = Article.get(params[:id])

    if article
      api_send_success_response(article.comments)
    else
      not_found
    end
  end

  api :post, '/articles/:id/comments', :authenticate => true do
    parent = Article.get(params[:id])

    if parent
      create_resource(Comment, :user => current_user, :parent => parent)
    else
      not_found
    end
  end

  api :get, '/comments/:id/comments' do
    comment = Comment.get(params[:id])

    if comment
      api_send_success_response(comment.comments)
    else
      not_found
    end
  end

  api :post, '/comments/:id/comments', :authenticate => true do
    parent = Comment.get(params[:id])

    if parent
      create_resource(Comment, :user => current_user, :parent => parent)
    else
      not_found
    end
  end

  api :delete, '/comments/:id', :authenticate => true do
    comment = Comment.get(params[:id])

    if comment
      if comment.user != current_user
        api_send_response(403, {'errors' => ["You may not delete others' comments"]})
      else
        comment.remove
        api_send_success_response(nil)
      end
    else
      not_found
    end
  end

  # Votes
  api :post, '/articles/:id/votes', :authenticate => true do
    target = Article.get(params[:id])

    if target
      create_resource(Vote, :user => current_user, :target => target)
    else
      not_found
    end
  end

  api :post, '/comments/:id/votes', :authenticate => true do
    target = Comment.get(params[:id])

    if target
      create_resource(Vote, :user => current_user, :target => target)
    else
      not_found
    end
  end

  private

  def create_resource(klass, additional_attributes = {})
    resource = klass.new(parsed_attributes.merge(additional_attributes))

    if resource.save
      api_send_success_response(resource, 201)
    else
      api_send_error_response(resource)
    end
  end

  def fetch_resource(klass, id)
    resource = klass.get(id)

    if resource
      api_send_success_response(resource)
    else
      not_found
    end
  end

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