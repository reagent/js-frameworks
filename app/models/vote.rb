class Vote
  include DataMapper::Resource
  extend Polymorphism

  property :id,          Serial
  property :user_id,     Integer, :required => true

  belongs_to :user

  polymorphic_belongs_to :target

  validates_uniqueness_of :user_id,
                          :scope => [:target_id, :target_type],
                          :message => "You've already voted for this item"

end