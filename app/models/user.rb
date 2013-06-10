class User
  include DataMapper::Resource
  extend Timestamps

  property :id,               Serial
  property :email,            String, :required => true, :unique => true
  property :username,         String, :required => true, :unique => true
  property :crypted_password, BCryptHash

  enable_timestamps

  has 1, :token,    :constraint => :destroy
  has n, :articles, :constraint => :set_nil
  has n, :comments, :constraint => :set_nil
  has n, :votes,    :constraint => :destroy

  attr_accessor :password, :password_confirmation

  validates_presence_of :password, :if => :new?
  validates_confirmation_of :password

  before :save, :crypt_password_if_required

  def favorites
    @favorites ||= Article.find_by_sql("
      SELECT articles.*
      FROM   articles
      JOIN   votes ON votes.target_id = articles.id AND votes.target_type = 'Article'
      WHERE  votes.user_id = #{id}
    ")
  end

  def reload
    self.password              = nil
    self.password_confirmation = nil

    super
  end

  def points
    @points ||= KarmaCalculator.new(self).points
  end

  def as_json(*opts)
    {:id => id, :points => points, :username => username, :email => email}
  end

  private

  def crypt_password_if_required
    self.crypted_password = password if crypt_password?
  end

  def crypt_password?
    crypted_password.nil?
  end

end