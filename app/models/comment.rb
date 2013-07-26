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

  def reply_count
    Comment.count(:parent_id => id, :parent_type => self.class.to_s)
  end

  def comment_count
    # TODO: optimize
    if comments.any?
      comments.inject(reply_count) {|s, c| s += c.comment_count }
    else
      0
    end
  end

  def as_json(*opts)
    {
      :id            => id,
      :body          => body,
      :user_id       => user_id,
      :username      => user.username,
      :points        => points,
      :comment_count => comment_count
    }
  end

end