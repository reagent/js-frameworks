require File.expand_path(File.dirname(__FILE__) + '../../spec_helper')

describe User do

  describe "validations" do
    it "requires an email" do
      subject.valid?
      subject.errors[:email].should_not be_empty
    end

    it "requires a unique email" do
      email = 'user@host.com'
      Factory(:user, :email => email)

      subject = described_class.new(:email => email)
      subject.valid?
      subject.errors[:email].should_not be_empty
    end

    it "requires a password on a new record" do
      subject.valid?
      subject.errors[:password].should_not be_empty
    end

    it "does not require a password confirmation when no password is supplied" do
      subject = described_class.new(:password => ' ')
      subject.valid?
      subject.errors[:password_confirmation].should be_empty
    end

    it "requires a password confirmation when a password is supplied" do
      subject = described_class.new(:password => 'sekrit')
      subject.valid?

      subject.errors[:password].should_not be_empty
    end

    it "knows when the password matches the confirmation" do
      subject = described_class.new(:password => 'sekrit', :password_confirmation => 'sekrit')
      subject.valid?

      subject.errors[:password].should be_empty
    end

    it "does not require a password on an existing record" do
      subject = described_class.get(Factory(:user).id)
      subject.valid?

      subject.errors[:password].should be_empty
    end
  end

  describe "#crypted_password" do
    let(:password) { 'sekrit' }

    subject { Factory.build(:user, :password => password, :password_confirmation => password) }

    it "is created on save" do
      expect { subject.save }.to change { subject.crypted_password }.from(nil)
    end

    it "is encrypted" do
      subject.save
      password_string = subject.crypted_password.to_s

      password_string.should_not == password
      BCrypt::Password.new(password_string).should == password
    end
  end

  describe "#as_json" do
    it "generates a JSON representation" do
      subject = Factory(:user, :email => 'user@host.com')
      subject.as_json.should == {:id => subject.id, :email => 'user@host.com'}
    end
  end

end