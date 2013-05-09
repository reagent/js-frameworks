class Comment
  include DataMapper::Resource

  property :id,          Serial
  property :user_id,     Integer, :required => true
  property :body,        Text,    :required => true
  property :parent_id,   Integer, :required => true
  property :parent_type, String,  :required => true

  belongs_to :user

  validates_with_method :parent, :method => :confirm_parent_set

  def parent=(parent)
    if parent
      self.parent_id   = parent.id
      self.parent_type = parent.class.to_s
    else
      self.parent_id   = nil
      self.parent_type = nil
    end
  end

  def parent
    Object.const_get(parent_type).get(parent_id) if parent_set?
  end

  def comments
    @comments ||= Comment.all(:parent_id => id, :parent_type => 'Comment')
  end

  def remove
    update(:body => '[removed]')
  end

  def as_json(*opts)
    {:id => id, :body => body}
  end

  private

  def parent_set?
    parent_id && parent_type
  end

  def confirm_parent_set
    if parent_set?
      true
    else
      [false, 'Requires a parent']
    end
  end
end