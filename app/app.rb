require 'rubygems'
require 'bundler/setup'

require 'sinatra/base'

$:.unshift(File.dirname(__FILE__))

require 'config/boot'
require 'config/disable_logging'

class App < Sinatra::Base

  configure do
    set :public_folder, ENV['JS_APP_PATH'] || File.expand_path(File.dirname(__FILE__) + '/../html')
    enable :logging
  end

  after { log_request }

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
    update_current_account
  end

  api :patch, '/account', :authenticate => true do
    update_current_account
  end

  api :get, '/account/favorites', :authenticate => true do
    fetch_association(current_user, :favorites)
  end

  api :delete, '/account', :authenticate => true do
    if current_user.destroy
      api_send_success_response(nil)
    else
      api_send_error_response(current_user)
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

  api :get, '/users/:id/articles' do
    fetch_resource(User, params[:id], :articles)
  end

  api :get, '/account/articles', :authenticate => true do
    fetch_association(current_user, :articles)
  end

  # Comments
  api :get, '/comments/:id' do
    fetch_resource(Comment, params[:id])
  end

  api :get, '/articles/:id/comments' do
    fetch_resource(Article, params[:id], :comments)
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
    fetch_resource(Comment, params[:id], :comments)
  end

  api :post, '/comments/:id/comments', :authenticate => true do
    parent = Comment.get(params[:id])

    if parent
      create_resource(Comment, :user => current_user, :parent => parent)
    else
      not_found
    end
  end

  api :get, '/users/:id/comments' do
    fetch_resource(User, params[:id], :comments)
  end

  api :get, '/account/comments', :authenticate => true do
    fetch_association(current_user, :comments)
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

  get '*' do
    request_path = params[:splat].first

    if can_serve_static_file?(request_path)
      send_file static_path_for(request_path)
    else
      pass
    end
  end

  private

  def can_serve_static_file?(virtual_path)
    if %r{\.\w+$} === virtual_path
      false
    else
      File.exist?(static_path_for(virtual_path))
    end
  end

  def static_path_for(virtual_path)
    path = settings.public_folder + virtual_path
    path.sub!(%r{/?$}, "/index.html") if File.directory?(path)

    path
  end

  def create_resource(klass, additional_attributes = {})
    resource = klass.new(parsed_attributes.merge(additional_attributes))

    if resource.save
      api_send_success_response(resource, 201)
    else
      api_send_error_response(resource)
    end
  end

  def fetch_resource(klass, id, association_name = nil)
    resource = klass.get(id)

    if resource
      if !association_name.nil?
        fetch_association(resource, association_name)
      else
        api_send_success_response(resource)
      end
    else
      not_found
    end
  end

  def fetch_association(instance, association_name)
    api_send_success_response(instance.send(association_name))
  end

  def update_current_account
    if current_user.update(parsed_attributes)
      api_send_success_response(current_user)
    else
      api_send_error_response(current_user)
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

  def api_send_error_response(object, status_code = 422)
    api_send_response(status_code, {
      :errors => {
        :keyed => object.errors.keyed,
        :full  => object.errors.values.flatten
      }
    })
  end

  def api_send_response(status_code, data_to_send = nil)
    body = data_to_send ? data_to_send.to_json : 'null'
    [status_code, response_headers, body]
  end

  def json_content_type
    'application/json'
  end

  def response_headers
    {'Content-Type' => json_content_type}
  end

  def parsed_attributes
    JSON.parse(request_body)
  end

  def accept_media_types
    raw_accept_header.split(/, ?/).map {|mt| extract_type_from(mt) }
  end

  def extract_type_from(media_type_string)
    media_type_string.split(/; ?/).first
  end

  def raw_accept_header
    request.env['HTTP_ACCEPT'] || ''
  end

  def content_type_header
    if request.env['CONTENT_TYPE']
      [extract_type_from(request.env['CONTENT_TYPE'])]
    end
  end

  def request_media_types
    [content_type_header, accept_media_types].compact.first
  end

  def request_body
    @request_body ||= request.body.read
  end

  def json_request?
    request_media_types.include?(json_content_type)
  end

  def log_request
    header_keys = ['CONTENT_TYPE', 'HTTP_ACCEPT', 'HTTP_X_USER_TOKEN']

    dumped_headers = header_keys.inject([]) do |pairs, key|
      if request.env.has_key?(key)
        name = key.sub(/^HTTP_/, '').titleize.gsub(' ', '-')
        pairs << "'#{name}': '#{request.env[key]}'"
      end
      pairs
    end.join(',')


    log_message = "
  -> #{request.env['REQUEST_METHOD']} #{request.env['REQUEST_URI']} #{response.status}

       Headers: {#{dumped_headers}}
    Parameters: #{params.inspect}
          Body: '#{request_body}'"

    request.logger.info(log_message)
  end

end
