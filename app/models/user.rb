class User
  include DataMapper::Resource

  property :id,               Serial
  property :email,            String, :required => true, :unique => true
  property :crypted_password, BCryptHash

  has 1, :token

  attr_accessor :password, :password_confirmation

  validates_presence_of :password, :if => :new?
  validates_confirmation_of :password

  before :save, :crypt_password

  def to_json
    {
      :id    => id,
      :email => email
    }.to_json
  end

  private

  def crypt_password
    self.crypted_password = password
  end

end