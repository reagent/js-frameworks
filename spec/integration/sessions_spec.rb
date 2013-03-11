require File.expand_path(File.dirname(__FILE__) + '../../spec_helper')

describe "Sessions", :type => :integration do

  describe "create" do
    let(:email)      { 'user@host.com' }
    let(:password)   { 'password' }
    let(:attributes) { {:email => email, :password => password} }

    it "requires the Content Type to be set" do
      post('/sessions', '{}').should have_api_status(:not_acceptable).and_have_no_body
    end

    it "creates the session and returns the correct response" do
      Factory(:user, :email => email, :password => password, :password_confirmation => password)

      api_post('/sessions', attributes) do |response|
        response.should have_api_status(:ok)
        response.should have_response_body({'token' => User.last.token.value})
      end
    end

    it "does not create the session when there is an error" do
      api_post('/sessions', attributes) do |response|
        response.should_have_api_status(:bad_request)
        response.should have_response_body({'errors' => ['Invalid email / password combination']})
      end
    end
  end

end