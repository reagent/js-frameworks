class User
  include DataMapper::Resource

  property :id,               Serial
  property :email,            String, :required => true, :unique => true
  property :username,         String, :required => true, :unique => true
  property :crypted_password, BCryptHash

  has 1, :token
  has n, :articles

  attr_accessor :password, :password_confirmation

  validates_presence_of :password, :if => :new?
  validates_confirmation_of :password

  before :save, :crypt_password

  def as_json(*opts)
    {:id => id, :username => username, :email => email}
  end

  private

  def crypt_password
    self.crypted_password = password
  end

end