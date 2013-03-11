require File.expand_path(File.dirname(__FILE__) + '../../spec_helper')

describe "Accounts", :type => :integration do
  describe "creation" do
    it "requires the Content Type to be set" do
      post('/users', '{}').should have_api_status(:not_acceptable).and_have_no_body
    end

    it "creates a user and returns the correct response" do
      valid_attributes = {
        :email                 => 'user@host.com',
        :password              => 'password',
        :password_confirmation => 'password'
      }

      expect { api_post('/users', valid_attributes) }.to change { User.count }.by(1)

      last_response.should have_api_status(:created)
      last_response.should have_response_body({'id' => User.last.id, 'email' => 'user@host.com'})
    end

    it "does not create the user when there is an error" do
      invalid_attributes = {}

      expect { api_post('/users', invalid_attributes) }.to_not change { User.count }

      last_response.should have_api_status(:bad_request)
      last_response.should have_response_body({'errors' => ['Email must not be blank', 'Password must not be blank']})
    end
  end
end