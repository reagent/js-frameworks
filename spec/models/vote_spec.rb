require 'spec_helper'

describe Vote do

  describe "validations" do
    it "requires a user" do
      subject.valid?
      subject.errors[:user_id].should_not be_empty
    end

    it "requires a target" do
      subject.valid?
      subject.errors[:target].should == ['is required']
    end

    it "only allows one vote for an article" do
      described_class.create!(:user_id => 1, :target_id => 1, :target_type => 'Article')
      described_class.create!(:user_id => 1, :target_id => 1, :target_type => 'Comment')

      subject = described_class.new(:user_id => 1, :target_id => 1, :target_type => 'Article')
      subject.valid?

      subject.errors[:user_id].should_not be_empty
    end

    it "only allows one vote for a comment" do
      described_class.create!(:user_id => 1, :target_id => 1, :target_type => 'Article')
      described_class.create!(:user_id => 1, :target_id => 1, :target_type => 'Comment')

      subject = described_class.new(:user_id => 1, :target_id => 1, :target_type => 'Comment')
      subject.valid?

      subject.errors[:user_id].should_not be_empty
    end
  end

  describe "#target=" do
    it "unsets the associated attributes" do
      subject = described_class.new(:target_id => 1, :target_type => 'Article')

      subject.target = nil

      subject.target_id.should be_nil
      subject.target_type.should be_nil
    end

    it "sets the attributes when assigning an Article" do
      article = Factory(:article)

      subject.target = article

      subject.target_id.should == article.id
      subject.target_type.should == 'Article'
    end

    it "sets the attributes when assigning a Comment" do
      comment = Factory(:comment)

      subject.target = comment

      subject.target_id.should == comment.id
      subject.target_type.should == 'Comment'
    end
  end

  describe "#target" do
    it "is nil by default" do
      subject.target.should be_nil
    end

    it "returns the associated article when set" do
      article = Factory(:article)
      subject = described_class.new(:target_id => article.id, :target_type => 'Article')

      subject.target.should == article
    end

    it "returns the associated comment when set" do
      comment = Factory(:comment)
      subject = described_class.new(:target_id => comment.id, :target_type => 'Comment')

      subject.target.should == comment
    end
  end

  describe "#as_json" do
    it "returns a representation of itself" do
      comment = Factory(:comment)
      subject = described_class.create!(:user => Factory(:user), :target => comment)

      subject.as_json.should == {:id => subject.id}
    end
  end

end