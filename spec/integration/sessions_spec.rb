require File.expand_path(File.dirname(__FILE__) + '../../spec_helper')

describe "Sessions", :type => :integration do

  describe "login" do
    let(:email)      { 'user@host.com' }
    let(:password)   { 'password' }
    let(:attributes) { {:email => email, :password => password} }

    requires_content_type_header_for(:post, '/session')

    it "creates the session and returns the correct response" do
      user = Factory(:user, :email => email, :password => password, :password_confirmation => password)

      api_post('/session', attributes) do |response|
        response.should have_api_status(:ok)
        response.should have_response_body({:token => user.token.value})
      end
    end

    it "does not create the session when there is an error" do
      api_post('/session', attributes) do |response|
        response.should_have_api_status(:unprocessable_entity)
        response.should have_response_body({:errors => ['Invalid email / password combination']})
      end
    end
  end

  describe "logout" do
    requires_content_type_header_for(:delete, '/session')
    requires_authentication_for(:delete, '/session')

    it "destroy's the user's current token" do
      user  = Factory(:user)
      token = Factory(:token, :user => user)

      expect do
        api_delete('/session', {'HTTP_X_USER_TOKEN' => token.value})
      end.to change { user.reload.token }.to(nil)
    end
  end

end