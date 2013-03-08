require File.expand_path(File.dirname(__FILE__) + '../../spec_helper')

describe "Articles", :type => :integration do

  describe "Home page" do
    it "serves the HTML version of the page" do
      get '/'

      last_response.status.should == 200
      last_response.headers['Content-Type'].should include('text/html')
    end
  end

  describe "retrieving a list" do
    it "requires the content type to be set" do
      get('/articles')

      last_response.status.should == 403
      last_response.body.should be_empty
    end

    it "returns a collection of articles as JSON" do
      article_1 = Factory(:article, :title => 'One', :url => 'http://example.org/one')
      article_2 = Factory(:article, :title => 'Two', :url => 'http://example.org/two')

      api_get('/articles')

      last_response.status.should == 200
      last_response.headers['Content-Type'].should == 'application/json'

      expected = [
        {'id' => article_1.id, 'title' => 'One', 'url' => 'http://example.org/one'},
        {'id' => article_2.id, 'title' => 'Two', 'url' => 'http://example.org/two'}
      ]

      last_response.body.should == JSON.generate(expected)
    end
  end

  describe "create" do
    it "requires a user" do
      attributes = {:title => 'One', :url => 'http://example.org'}
      api_post('/articles', attributes)

      last_response.status.should == 401
      last_response.body.should == JSON.generate({'errors' => ['Authentication is required']})
    end

    it "can create an article when there is a valid user" do
      attributes = {:title => 'One', :url => 'http://example.org'}

      token = Factory(:token)
      user  = token.user

      expect do
        api_post('/articles', attributes, {'HTTP_X_USER_TOKEN' => token.value})
      end.to change { user.articles.count }.by(1)

      last_response.status.should == 200
      last_response.headers['Content-Type'].should == 'application/json'

      last_response.body.should == JSON.generate({'id' => Article.last.id, 'title' => 'One', 'url' => 'http://example.org'})
    end

    it "returns errors when creation fails" do
      token = Factory(:token)
      user  = token.user

      expect do
        api_post('/articles', {}, {'HTTP_X_USER_TOKEN' => token.value})
      end.to_not change { user.articles.count }

      last_response.status.should == 400
      last_response.headers['Content-Type'].should == 'application/json'

      last_response.body.should == JSON.generate({'errors' => ['Title must not be blank', 'URL must not be blank']})
    end
  end

  describe "fetching a single article" do
    it "returns a 404 when it does not exist" do
      api_get('/articles/1')

      last_response.status.should == 404
      last_response.headers['Content-Type'].should == 'application/json'

      last_response.body.should be_empty
    end

    it "returns the article" do
      article = Factory(:article, :title => 'One', :url => 'http://example.org/one')

      api_get("/articles/1")

      last_response.status.should == 200
      last_response.headers['Content-Type'].should == 'application/json'

      last_response.body.should == JSON.generate({'id' => article.id, 'title' => 'One', 'url' => 'http://example.org/one'})
    end
  end

end