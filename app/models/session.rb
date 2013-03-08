class Session
  include DataMapper::Validations

  attr_accessor :email, :password
  validates_presence_of :email, :password

  validates_with_method :user, :method => :matching_user_exists

  def initialize(attributes = {})
    attributes.each {|k, v| send("#{k}=", v) }
  end

  def authenticate
    if !instance_variable_defined?(:@authenticated)
      @authenticated = (valid? && matching_user) ? save_user_token : false
    end
    @authenticated
  end

  def as_json(*opts)
    authenticated? ? matching_user_token.as_json(*opts) : {}
  end

  private

  def authenticated?
    authenticate == true
  end

  def matching_user_token
    matching_user.token
  end

  def matching_user
    @matching_user ||= begin
      user = User.first(:email => email)
      user if user && user.crypted_password == password
    end
  end

  def save_user_token
    if matching_user.token.nil?
      matching_user.token = Token.create
      matching_user.save
    end

    true
  end

  def matching_user_exists
    if matching_user
      true
    else
      [false, "Invalid email / password combination"]
    end
  end

end