require File.expand_path(File.dirname(__FILE__) + '../../spec_helper')

describe "Articles", :type => :integration do
  before do
    Timecop.freeze(Time.local(2013))
  end

  after do
    Timecop.return
  end

  describe "retrieving a list" do
    requires_content_type_header_for(:get, '/articles')

    it "returns a collection of articles as JSON" do
      article_1 = Factory(:article, :title => 'One', :url => 'http://example.org/one')
      article_2 = Factory(:article, :title => 'Two', :url => 'http://example.org/two')

      expected = [
        {
          :id => article_1.id,
          :points => 1,
          :title => 'One',
          :url => 'http://example.org/one',
          :created_at => '2013-01-01T00:00:00-04:00',
          :updated_at => '2013-01-01T00:00:00-04:00'
        },
        {
          :id => article_2.id,
          :points => 1,
          :title => 'Two',
          :url => 'http://example.org/two',
          :created_at => '2013-01-01T00:00:00-04:00',
          :updated_at => '2013-01-01T00:00:00-04:00'
        }
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
      last_response.should have_response_body({:errors => ['Authentication is required']})
    end

    it "can create an article when there is a valid user" do
      attributes = {:title => 'One', :url => 'http://example.org'}

      token = Factory(:token)
      user  = token.user

      expect do
        api_post('/articles', attributes, {'HTTP_X_USER_TOKEN' => token.value})
      end.to change { user.articles.count }.by(1)

      last_response.should have_api_status(:created)
      last_response.should have_response_body(
        {
          :id         => Article.last.id,
          :points     => 1,
          :title      => 'One',
          :url        => 'http://example.org',
          :created_at => '2013-01-01T00:00:00-04:00',
          :updated_at => '2013-01-01T00:00:00-04:00'
        })
    end

    it "returns errors when creation fails" do
      token = Factory(:token)
      user  = token.user

      expect do
        api_post('/articles', {}, {'HTTP_X_USER_TOKEN' => token.value})
      end.to_not change { user.articles.count }

      last_response.should have_api_status(:unprocessable_entity)
      last_response.should have_response_body({
        :errors => {
          :keyed => {:title => ['Title must not be blank'], :url => ['URL must not be blank']},
          :full  => ['Title must not be blank', 'URL must not be blank']
        }
      })
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
      last_response.should have_response_body(
        {
          :id         => article.id,
          :points     => 1,
          :title      => 'One',
          :url        => 'http://example.org/one',
          :created_at => '2013-01-01T00:00:00-04:00',
          :updated_at => '2013-01-01T00:00:00-04:00'
        })
    end
  end

  describe "fetching a User's posted articles" do
    requires_content_type_header_for(:get, '/users/1/articles')

    it "returns a 404 when the user does not exist" do
      api_get('/users/1/articles').should have_api_status(:not_found).and_have_no_body
    end

    it "returns the user's posted articles" do
      user_1 = Factory(:user)
      user_2 = Factory(:user)

      article_1 = Factory(:article, :user => user_1, :title => 'Foo', :url => 'http://example.com')
      article_2 = Factory(:article, :user => user_2)

      api_get("/users/#{user_1.id}/articles")

      last_response.should have_api_status(:ok)
      last_response.should have_response_body([
        {
          :id         => article_1.id,
          :points     => 1,
          :title      => 'Foo',
          :url        => 'http://example.com',
          :created_at => '2013-01-01T00:00:00-04:00',
          :updated_at => '2013-01-01T00:00:00-04:00'
        }])
    end
  end

  describe "fetching the current user's posted articles" do
    requires_content_type_header_for(:get, '/account/articles')
    requires_authentication_for(:get, '/account/articles')

    it "returns the list of articles" do
      token  = Factory(:token)

      user_1 = token.user
      user_2 = Factory(:user)

      article_1 = Factory(:article, :user => user_1, :title => 'Foo', :url => 'http://example.com')
      article_2 = Factory(:article, :user => user_2)

      api_get('/account/articles', {}, {'HTTP_X_USER_TOKEN' => token.value})

      last_response.should have_api_status(:ok)
      last_response.should have_response_body([
        {
          :id         => article_1.id,
          :points     => 1,
          :title      => 'Foo',
          :url        => 'http://example.com',
          :created_at => '2013-01-01T00:00:00-04:00',
          :updated_at => '2013-01-01T00:00:00-04:00'
        }])
    end
  end

end