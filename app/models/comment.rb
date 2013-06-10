class Comment
  include DataMapper::Resource
  extend Timestamps
  extend Polymorphism

  property :id,      Serial
  property :user_id, Integer
  property :body,    Text,    :required => true

  enable_timestamps

  belongs_to :user

  polymorphic_belongs_to :parent

  polymorphic_many :comments, :as => :parent
  polymorphic_many :votes,    :as => :target

  def remove
    update(:body => '[removed]')
  end

  def points
    Vote.count(:target_id => id, :target_type => self.class.to_s)
  end

  def as_json(*opts)
    {:id => id, :points => points, :body => body}
  end

end