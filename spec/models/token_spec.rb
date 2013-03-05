require File.expand_path(File.dirname(__FILE__) + '../../spec_helper')

describe Token do

  describe "validations" do
    it "requires a user" do
      subject.valid?
      subject.errors[:user_id].should_not be_empty
    end
  end

end

