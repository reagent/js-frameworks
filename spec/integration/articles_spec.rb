require File.expand_path(File.dirname(__FILE__) + '../../spec_helper')

describe "Articles", :type => :integration do

  describe "Home page" do
    it "serves the HTML version of the page" do
      get('/') do |response|
        response.should have_status(:ok)
        response.should have_content_type('text/html')
      end
    end
  end

  describe "retrieving a list" do
    requires_content_type_header_for(:get, '/articles')

    it "returns a collection of articles as JSON" do
      article_1 = Factory(:article, :title => 'One', :url => 'http://example.org/one')
      article_2 = Factory(:article, :title => 'Two', :url => 'http://example.org/two')

      expected = [
        {'id' => article_1.id, 'title' => 'One', 'url' => 'http://example.org/one'},
        {'id' => article_2.id, 'title' => 'Two', 'url' => 'http://example.org/two'}
      ]

      api_get('/articles').should have_api_status(:ok).and_response_body(expected)
    end
  end

  describe "create" do
    requires_content_type_header_for(:post, '/articles')
    requires_authentication_for(:post, '/articles')

    it "requires a user" do
      attributes = {:title => 'One', :url => 'http://example.org'}
      api_post('/articles', attributes)

      last_response.should have_api_status(:unauthorized)
      last_response.should have_response_body({'errors' => ['Authentication is required']})
    end

    it "can create an article when there is a valid user" do
      attributes = {:title => 'One', :url => 'http://example.org'}

      token = Factory(:token)
      user  = token.user

      expect do
        api_post('/articles', attributes, {'HTTP_X_USER_TOKEN' => token.value})
      end.to change { user.articles.count }.by(1)

      last_response.should have_api_status(:ok)
      last_response.should have_response_body({'id' => Article.last.id, 'title' => 'One', 'url' => 'http://example.org'})
    end

    it "returns errors when creation fails" do
      token = Factory(:token)
      user  = token.user

      expect do
        api_post('/articles', {}, {'HTTP_X_USER_TOKEN' => token.value})
      end.to_not change { user.articles.count }

      last_response.should have_api_status(:bad_request)
      last_response.should have_response_body({'errors' => ['Title must not be blank', 'URL must not be blank']})
    end
  end

  describe "fetching a single article" do
    requires_content_type_header_for(:get, '/articles/1')

    it "returns a 404 when it does not exist" do
      api_get('/articles/1').should have_api_status(:not_found).and_have_no_body
    end

    it "returns the article" do
      article = Factory(:article, :title => 'One', :url => 'http://example.org/one')

      api_get('/articles/1')

      last_response.should have_api_status(:ok)
      last_response.should have_response_body({'id' => article.id, 'title' => 'One', 'url' => 'http://example.org/one'})
    end
  end

end