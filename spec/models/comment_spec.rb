require 'spec_helper'

describe Comment do

  describe "validations" do
    it "requires a body" do
      subject.valid?
      subject.errors[:body].should_not be_empty
    end

    it "requires a parent" do
      subject.valid?
      subject.errors[:parent].should == ['is required']
    end
  end

  describe "#parent=" do
    it "unsets the associated attributes" do
      subject = described_class.new(:parent_id => 1, :parent_type => 'Article')
      subject.parent = nil

      subject.parent_id.should be_nil
      subject.parent_type.should be_nil
    end

    it "sets the attributes when associating an Article" do
      article = Factory(:article)
      subject.parent = article

      subject.parent_id.should == article.id
      subject.parent_type.should == 'Article'
    end

    it "sets the attributes when associating a Comment" do
      comment = Factory(:comment)
      subject.parent = comment

      subject.parent_id.should == comment.id
      subject.parent_type.should == 'Comment'
    end
  end

  describe "#parent" do
    it "is nil by default" do
      subject.parent.should be_nil
    end

    it "returns the associated article when set" do
      article = Factory(:article)
      subject = described_class.new(:parent_id => article.id, :parent_type => 'Article')

      subject.parent.should == article
    end

    it "returns the associated comment when set" do
      comment = Factory(:comment)
      subject = described_class.new(:parent_id => comment.id, :parent_type => 'Comment')

      subject.parent.should == comment
    end
  end

  describe "#comments" do
    it "is empty by default" do
      subject.comments.should == []
    end

    it "returns the list of associated comments" do
      parent = Factory(:comment)
      child  = Factory(:comment, :parent => parent)

      other = Factory(:comment)

      parent.comments.should == [child]
    end
  end

  describe "#votes" do
    it "is empty by default" do
      subject.votes.should == []
    end

    it "returns a list of associated votes" do
      subject = Factory(:comment)
      vote    = Factory(:vote, :target => subject)
      other   = Factory(:vote)

      subject.votes.should == [vote]
    end
  end

  describe "#remove" do
    it "replaces the body content" do
      subject = Factory(:comment, :body => 'OMGHI2U')

      expect { subject.remove }.to change { subject.body }.from('OMGHI2U').to('[removed]')
    end
  end

  describe "#as_json" do
    it "returns a representation of itself" do
      subject = described_class.create!(:user => Factory(:user), :body => 'Hi there.')
      subject.as_json.should == {
        :id   => subject.id,
        :body => 'Hi there.'
      }
    end
  end

end