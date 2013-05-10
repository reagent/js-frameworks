class Vote
  include DataMapper::Resource

  property :id,          Serial
  property :user_id,     Integer, :required => true
  property :target_id,   Integer, :required => true
  property :target_type, String, :required => true

  belongs_to :user

  validates_uniqueness_of :user_id,
                          :scope => [:target_id, :target_type],
                          :message => "You've already voted for this item"

  validates_with_method :target, :method => :confirm_target_set

  def target=(target)
    if target
      self.target_id   = target.id
      self.target_type = target.class.to_s
    else
      self.target_id = nil
      self.target_type = nil
    end
  end

  def target
    Object.const_get(target_type).get(target_id) if target_set?
  end

  private

  def target_set?
    target_id && target_type
  end

  def confirm_target_set
    if target_set?
      true
    else
      [false, 'Requires a target']
    end
  end


end