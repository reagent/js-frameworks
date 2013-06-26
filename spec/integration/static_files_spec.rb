require File.expand_path(File.dirname(__FILE__) + '../../spec_helper')

describe "Static file request responses", :type => :integration do
  before do
    App::settings.stub(:public_folder) { './spec/fixtures' }
  end

  describe "GET '/' response" do
    subject { get('/') }

    it "responds with status 200" do
      subject.should have_status(:ok)
    end

    it "sends the contents of index.html" do
      subject.body.should == "oh, hay!"
    end
  end

  describe "GET '/subdirectory' response" do
    subject { get('/subdirectory')  }

    it "responds with status 200" do
      subject.should have_status(:ok)
    end

    it "sends the contents of index.html" do
      subject.body.should == 'omg! subdir.'
    end
  end

  describe "GET '[some static file]' response" do
    context "when the requested file does not exist" do
      subject { get('/doesnt_exist.html') }

      it "responds with status 404" do
        subject.should have_status(:not_found)
      end
    end

    context "when the requested file exists" do
      let(:file_last_modified_at) { File.stat("#{app.public_folder}/index.html").mtime }

      context "and has not been modified since HTTP_IF_MODIFIED_SINCE" do
        subject { get('/index.html', {}, { "HTTP_IF_MODIFIED_SINCE" => file_last_modified_at.httpdate }) }

        it "responds with status 304" do
          subject.should have_status(:not_modified)
        end

        it "sends an empty body" do
          subject.body.should == ""
        end
      end

      context "and has been modified since HTTP_IF_MODIFIED_SINCE" do
        subject { get('/index.html', {}, { "HTTP_IF_MODIFIED_SINCE" => (file_last_modified_at - 1).httpdate }) }

        it "responds with status 200" do
          subject.should have_status(:ok)
        end

        it "responds with the proper body" do
          subject.body.should == "oh, hay!"
        end
      end
    end
  end
end