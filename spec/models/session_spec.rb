require File.expand_path(File.dirname(__FILE__) + '../../spec_helper')

describe Session do

  describe "validations" do
    it "requires an email" do
      subject.valid?
      subject.errors[:email].should_not be_empty
    end

    it "knows that the email has been set" do
      subject = described_class.new(:email => 'user@host.com')
      subject.valid?

      subject.errors[:email].should be_empty
    end

    it "requires a password" do
      subject.valid?
      subject.errors[:password].should_not be_empty
    end

    it "knows that the password has been set" do
      subject = described_class.new(:password => 'password')
      subject.valid?

      subject.errors[:password].should be_empty
    end

    it "knows the user does not exist" do
      subject = described_class.new(:email => 'user@host.com', :password => 'password')
      subject.valid?

      subject.errors[:user].should include('Invalid email / password combination')
    end

    it "knows the user exists" do
      user = Factory(:user, :email => 'user@host.com', :password => 'password', :password_confirmation => 'password')

      subject = described_class.new(:email => 'user@host.com', :password => 'password')
      subject.valid?

      subject.errors[:user].should be_empty
    end
  end

  describe "#authenticate" do
    let(:email)    { 'user@host.com' }
    let(:password) { 'password'}

    subject { described_class.new(:email => email, :password => password) }

    context "when unsuccessful" do
      it "returns false" do
        subject.authenticate.should be(false)
      end

      it "does not create a token" do
        expect { subject.authenticate }.to_not change { Token.count }
      end

      it "sets errors" do
        subject.authenticate
        subject.errors[:user].should_not be_empty
      end
    end

    context "when successful" do
      let!(:user) { Factory(:user, :email => email, :password => password, :password_confirmation => password) }

      it "returns true" do
        subject.authenticate.should be(true)
      end

      it "creates a new token" do
        expect { subject.authenticate }.to change { user.token }.from(nil)
      end

      it "does not set any errors" do
        subject.authenticate
        subject.errors.should be_empty
      end

      it "does not create a token if one exists" do
        user.token = Token.create
        user.save

        expect { subject.authenticate }.to_not change { user.token }
      end
    end
  end

  describe "#to_json" do
    it "returns a JSON representation of itself" do
      user  = Factory(:user, :email => 'user@host.com', :password => 'password', :password_confirmation => 'password')
      token = Token.create

      user.token = token
      user.save

      subject = described_class.new(:email => 'user@host.com', :password => 'password')
      subject.to_json.should == {:token => token.value}.to_json
    end

    it "returns an empty JSON object when it can't authenticate" do
      subject = described_class.new(:email => 'user@host.com', :password => 'password')
      subject.to_json.should == {}.to_json
    end
  end

end