class Token
  include DataMapper::Resource

  property :user_id, Integer, :required => true
  property :value,   APIKey, :key => true, :required => true, :unique => true

  belongs_to :user

end