module IntegrationSpecHelper
  include Rack::Test::Methods

  def app
    App
  end

  def api_post(path, attributes, headers = {})
    post(path, attributes.to_json, api_request_headers.merge(headers))
  end

  def api_get(path, attributes = {}, headers = {})
    get(path, attributes, api_request_headers.merge(headers))
  end

  def api_put(path, attributes, headers = {})
    put(path, attributes.to_json, api_request_headers.merge(headers))
  end

  def api_delete(path, headers = {})
    delete(path, nil, api_request_headers.merge(headers))
  end

  def api_request_headers
    {'CONTENT_TYPE' => 'application/json'}
  end

end