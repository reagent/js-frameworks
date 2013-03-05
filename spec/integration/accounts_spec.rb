require File.expand_path(File.dirname(__FILE__) + '../../spec_helper')

describe "Accounts", :type => :integration do
  describe "creation" do
    it "requires the Content Type to be set" do
      post '/users', {}.to_json

      last_response.status.should == 403
      last_response.body.should be_empty
    end

    it "creates a user and returns the correct response" do
      valid_attributes = {
        :email                 => 'user@host.com',
        :password              => 'password',
        :password_confirmation => 'password'
      }

      expect { api_post('/users', valid_attributes) }.to change { User.count }.by(1)

      last_response.status.should == 201
      last_response.headers['Content-Type'].should == 'application/json'

      last_user = User.last
      last_response.body.should == last_user.to_json
    end

    it "does not create the user when there is an error" do
      invalid_attributes = {}

      expect { api_post('/users', invalid_attributes) }.to_not change { User.count }

      last_response.status.should == 400
      last_response.headers['Content-Type'].should == 'application/json'

      JSON.parse(last_response.body).should == {'errors' => ['Email must not be blank', 'Password must not be blank']}
    end
  end
end