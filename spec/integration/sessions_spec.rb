require File.expand_path(File.dirname(__FILE__) + '../../spec_helper')

describe "Sessions", :type => :integration do

  describe "create" do
    let(:email)      { 'user@host.com' }
    let(:password)   { 'password' }
    let(:attributes) { {:email => email, :password => password} }

    it "requires the Content Type to be set" do
      post '/sessions', {}.to_json

      last_response.status.should == 403
      last_response.body.should be_empty
    end

    it "creates the session and returns the correct response" do
      Factory(:user, :email => email, :password => password, :password_confirmation => password)

      api_post('/sessions', attributes)

      last_response.status.should == 200
      last_response.headers['Content-Type'].should == 'application/json'

      last_response.body.should == {:token => User.last.token.value}.to_json
    end

    it "does not create the session when there is an error" do
      api_post('/sessions', attributes)

      last_response.status.should == 400
      last_response.headers['Content-Type'].should == 'application/json'

      last_response.body.should == {:errors => ['Invalid email / password combination']}.to_json
    end
  end

end