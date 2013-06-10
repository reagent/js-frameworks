require 'spec_helper'

describe KarmaCalculator do

  describe "#points" do
    let(:user) { Factory(:user) }

    subject { described_class.new(user) }

    it "includes total votes on articles" do
      article_1 = Factory(:article, :user => user)
      article_2 = Factory(:article, :user => user)
      article_3 = Factory(:article) # Posted by another user

      Factory(:vote, :target => article_1)
      Factory(:vote, :target => article_1)
      Factory(:vote, :target => article_3)

      subject.points.should == 4
    end

    it "includes total votes on comments" do
      comment_1 = Factory(:comment, :user => user)
      comment_2 = Factory(:comment)

      Factory(:vote, :target => comment_1)
      Factory(:vote, :target => comment_2)

      subject.points.should == 1
    end
  end

end