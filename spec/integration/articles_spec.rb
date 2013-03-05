require File.expand_path(File.dirname(__FILE__) + '../../spec_helper')

describe "Articles", :type => :integration do

  describe "Home page" do
    it "serves the HTML version of the page" do
      get '/'

      last_response.status.should == 200
      last_response.headers['Content-Type'].should include('text/html')
    end
  end

end