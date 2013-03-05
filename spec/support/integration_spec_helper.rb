module IntegrationSpecHelper
  include Rack::Test::Methods

  def app
    App
  end

  def api_post(path, attributes)
    post(path, attributes.to_json, 'CONTENT_TYPE' => 'application/json')
  end
end
