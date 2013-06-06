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

    it "requires a username" do
      subject.valid?
      subject.errors[:username].should_not be_empty
    end

    it "requires a unique username" do
      username = 'username'
      Factory(:user, :username => username)

      subject = described_class.new(:username => username)
      subject.valid?

      subject.errors[:username].should_not be_empty
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

    it "doesn't get changed on save" do
      subject.save
      subject.reload

      subject.email = 'changed@example.com'

      expect { subject.save }.to_not change { subject.crypted_password.to_s }
    end
  end

  describe "#favorites" do
    it "returns a list of articles the user voted on" do
      subject = Factory(:user)
      user_2  = Factory(:user)

      article_1 = Factory(:article)
      article_2 = Factory(:article)
      article_3 = Factory(:article)

      Factory(:vote, :user => subject, :target => article_1)
      Factory(:vote, :user => subject, :target => article_3)
      Factory(:vote, :user => user_2, :target => article_1)
      Factory(:vote, :user => user_2, :target => article_2)

      subject.favorites.map(&:id).should =~ [article_1.id, article_3.id]
    end
  end

  describe "#as_json" do
    subject { Factory(:user, :username => 'username', :email => 'user@host.com') }

    it "generates a JSON representation" do
      expected = {
        :id       => subject.id,
        :username => 'username',
        :email    => 'user@host.com'
      }

      subject.as_json.should == expected
    end
  end

end