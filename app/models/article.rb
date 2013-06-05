class Article
  include DataMapper::Resource
  extend Polymorphism

  property :id,      Serial
  property :user_id, Integer, :required => true
  property :title,   String,  :required => true
  property :url,     URI

  belongs_to :user

  polymorphic_many :comments, :as => :parent
  polymorphic_many :votes,    :as => :target

  validates_presence_of :url, :message => 'URL must not be blank'

  validates_with_method :url, :method => :validate_url, :if => :url?

  def as_json(*opts)
    {:id => id, :title => title, :url => url.to_s}
  end

  private

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
      [false, 'is invalid']
    end
  end

end