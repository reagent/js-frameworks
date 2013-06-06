class Comment
  include DataMapper::Resource
  extend Polymorphism

  property :id,      Serial
  property :user_id, Integer
  property :body,    Text,    :required => true

  belongs_to :user

  polymorphic_belongs_to :parent

  polymorphic_many :comments, :as => :parent
  polymorphic_many :votes,    :as => :target

  def remove
    update(:body => '[removed]')
  end

  def as_json(*opts)
    {:id => id, :body => body}
  end

end