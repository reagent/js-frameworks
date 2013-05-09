require File.expand_path(File.dirname(__FILE__) + '../../spec_helper')

describe "Accounts", :type => :integration do
  describe "creation" do
    requires_content_type_header_for(:post, '/users')

    it "creates a user and returns the correct response" do
      valid_attributes = {
        :email                 => 'user@host.com',
        :username              => 'username',
        :password              => 'password',
        :password_confirmation => 'password'
      }

      expect { api_post('/users', valid_attributes) }.to change { User.count }.by(1)

      expected = {
        'id'       => User.last.id,
        'username' => 'username',
        'email'    => 'user@host.com'
      }

      last_response.should have_api_status(:created).and_response_body(expected)
    end

    it "does not create the user when there is an error" do
      invalid_attributes = {:email => 'user@host.com', :username => 'username'}

      expect { api_post('/users', invalid_attributes) }.to_not change { User.count }

      last_response.should have_api_status(:bad_request)
      last_response.should have_response_body({'errors' => ['Password must not be blank']})
    end
  end

  describe "fetching a public profile" do
    requires_content_type_header_for(:get, '/users/1')

    it "returns a 404 when the user is not found" do
      api_get('/users/1').should have_api_status(:not_found).and_have_no_body
    end

    it "returns a matching user" do
      user = Factory(:user, :username => 'username', :email => 'user@host.com')

      api_get("/users/#{user.id}")

      last_response.should have_api_status(:ok)
      last_response.should have_response_body({'id' => user.id, 'username' => 'username', 'email' => 'user@host.com'})
    end
  end

  describe "fetching the currently logged-in user" do
    requires_content_type_header_for(:get, '/current_user')
    requires_authentication_for(:get, '/current_user')

    it "returns the current user" do
      user = Factory(:user, {
        :username              => 'username',
        :email                 => 'user@host.com',
        :password              => 'password',
        :password_confirmation => 'password'
      })

      token = Factory(:token, :user => user)

      api_get('/current_user', {}, {'HTTP_X_USER_TOKEN' => token.value})

      last_response.should have_api_status(:ok)
      last_response.should have_response_body({'id' => user.id, 'username' => 'username', 'email' => 'user@host.com'})
    end
  end

  describe "updating the currently logged-in user" do
    requires_content_type_header_for(:put, '/current_user')
    requires_authentication_for(:put, '/current_user')

    it "updates the user's information" do
      user = Factory(:user, {
        :username              => 'username',
        :email                 => 'user@host.com',
        :password              => 'password',
        :password_confirmation => 'password'
      })

      token = Factory(:token, :user => user)

      expect do
        api_put('/current_user', {:username => 'foobar'}, {'HTTP_X_USER_TOKEN' => token.value})
      end.to change { user.reload.username }.from('username').to('foobar')

      last_response.should have_api_status(:ok)
      last_response.should have_response_body({'id' => user.id, 'username' => 'foobar', 'email' => 'user@host.com'})
    end

    it "responds with an error when the user cannot be updated" do
      Factory(:user, :username => 'username_1')
      user = Factory(:user, :username => 'username_2')

      token = Factory(:token, :user => user)

      api_put('/current_user', {:username => 'username_1'}, {'HTTP_X_USER_TOKEN' => token.value})

      last_response.should have_api_status(:unprocessable_entity)
      last_response.should have_response_body({'errors' => ['Username is already taken']})
    end
  end

  describe "deleting a user's account" do
    requires_content_type_header_for(:delete, '/current_user')
    requires_authentication_for(:delete, '/current_user')

    it "removes the user" do
      user = Factory(:user, {
        :username              => 'username',
        :email                 => 'user@host.com',
        :password              => 'password',
        :password_confirmation => 'password'
      })

      token = Factory(:token, :user => user)

      api_delete('/current_user', {'HTTP_X_USER_TOKEN' => token.value})

      last_response.should have_api_status(:ok).and_have_no_body

      User.get(user.id).should be_nil
    end
  end

end