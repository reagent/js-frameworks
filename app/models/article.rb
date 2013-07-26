class Article
  include DataMapper::Resource
  extend Timestamps
  extend Polymorphism

  property :id,      Serial
  property :user_id, Integer
  property :title,   String,  :required => true
  property :url,     URI

  enable_timestamps

  belongs_to :user

  polymorphic_many :comments, :as => :parent
  polymorphic_many :votes,    :as => :target

  validates_presence_of :url, :message => 'URL must not be blank'
  validates_with_method :url, :method  => :validate_url, :if => :url?

  after :save, :automatically_upvote

  def points
    Vote.count(:target_id => id, :target_type => self.class.to_s)
  end

  def reply_count
    Comment.count(:parent_id => id, :parent_type => self.class.to_s)
  end

  def comment_count
    reply_count + comments.inject(0) {|s, c| s += c.comment_count }
  end

  def as_json(*opts)
    {
      :id            => id,
      :title         => title,
      :url           => url.to_s,
      :user_id       => user_id,
      :username      => user.username,
      :points        => points,
      :comment_count => comment_count,
      :created_at    => created_at.to_s,
      :updated_at    => updated_at.to_s
    }
  end

  private

  def automatically_upvote
    user.votes.create(:target => self) if user_id
  end

  def url?
    !url.nil?
  end

  def validate_url
    begin
      if !%w(http https).include?(url.scheme)
        raise Addressable::URI::InvalidURIError
      else
        true
      end

    rescue Addressable::URI::InvalidURIError
      [false, 'URL is invalid']
    end
  end

end
