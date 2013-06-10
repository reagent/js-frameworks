class Vote
  include DataMapper::Resource
  extend Timestamps
  extend Polymorphism

  property :id,          Serial
  property :user_id,     Integer, :required => true

  enable_timestamps

  belongs_to :user

  polymorphic_belongs_to :target

  validates_uniqueness_of :user_id,
                          :scope => [:target_id, :target_type],
                          :message => "You've already voted for this item"

  def as_json(*opts)
    {:id => id}
  end

end