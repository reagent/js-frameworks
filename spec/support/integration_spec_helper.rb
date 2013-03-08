module IntegrationSpecHelper
  include Rack::Test::Methods

  def app
    App
  end

  def api_post(path, attributes, headers = {})
    post(path, attributes.to_json, api_request_headers.merge(headers))
  end

  def api_get(path, attributes = {})
    get(path, attributes, api_request_headers)
  end

  def api_request_headers
    {'CONTENT_TYPE' => 'application/json'}
  end
end
