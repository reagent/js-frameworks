require File.expand_path(File.dirname(__FILE__) + '../../spec_helper')

describe Article do

  describe "validations" do
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

      subject.errors[:url].should == ['is invalid']
    end

    it "knows that the URL is valid" do
      subject.url = 'http://example.org'
      subject.valid?

      subject.errors[:url].should be_empty
    end
  end

  describe "creation" do
    it "automatically tallies a vote for the user" do
      user = Factory(:user)

      subject = Factory.build(:article, :user => user)
      expect { subject.save }.to change { user.reload.votes.count }.from(0).to(1)

      user.votes.first.target.should == subject
    end
  end

  describe "#comments" do
    it "is empty by default" do
      subject.comments.should == []
    end

    it "returns a list of associated comments" do
      subject = Factory(:article)
      comment = Factory(:comment, :parent => subject)
      other   = Factory(:comment)

      subject.comments.should == [comment]
    end
  end

  describe "#votes" do
    it "is empty by default" do
      subject.votes.should == []
    end

    it "returns a list of associated votes" do
      subject = Factory(:article)
      vote    = Factory(:vote, :target => subject)
      other   = Factory(:vote)

      subject.votes.should include(vote)
    end
  end

  describe "#points" do
    it "is zero by default" do
      subject.points.should == 0
    end

    it "is the sum of all votes for the article" do
      subject = Factory(:article)
      other   = Factory(:article)

      Factory(:vote, :target => subject)
      Factory(:vote, :target => other)

      subject.points.should == 2 # Creating an article automatically adds a vote from the creator
    end
  end

  describe "#as_json" do
    before do
      Timecop.freeze(Time.local(2013))
    end

    after do
      Timecop.return
    end

    it "generates a JSON representation of itself" do
      subject = Factory(:article,
                        :title => 'A new article',
                        :url => 'http://example.org')

      subject.as_json.should == {
        :id     => subject.id,
        :points => 1,
        :title  => 'A new article',
        :url    => 'http://example.org',
        :created_at => '2013-01-01T00:00:00-04:00',
        :updated_at => '2013-01-01T00:00:00-04:00'
      }
    end
  end

end