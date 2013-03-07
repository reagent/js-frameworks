require File.expand_path(File.dirname(__FILE__) + '../../spec_helper')

describe Article do

  describe "validations" do
    it "requires a user" do
      subject.valid?
      subject.errors[:user_id].should_not be_empty
    end

    it "requires a title" do
      subject.valid?
      subject.errors[:title].should_not be_empty
    end

    it "requires a URL" do
      subject.valid?
      subject.errors[:url].should == ['URL must not be blank']
    end

    it "knows that the URL is invalid" do
      subject.url = 'bogon'
      subject.valid?

      subject.errors[:url].should == ['URL is invalid']
    end

    it "knows that the URL is valid" do
      subject.url = 'http://example.org'
      subject.valid?

      subject.errors[:url].should be_empty
    end
  end

  describe "#to_json" do
    it "generates a JSON representation of itself" do
      subject = described_class.create!(:title => 'A new article')
      subject.to_json.should == {:id => subject.id, :title => 'A new article'}.to_json
    end
  end

end