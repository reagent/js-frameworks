require 'factory_girl'

FactoryGirl.define do
  factory :user do
    sequence(:email)      {|n| "user_#{n}@host.com" }
    password              'sekrit'
    password_confirmation 'sekrit'
  end

  factory :token do
    user
  end

  factory :article do
    user
    title 'Blah Blah Blah'
    url   'http://www.example.org'
  end
end

def Factory(*args)
  Factory.create(*args)
end

class Factory
  class SaveError < RuntimeError; end

  def self.create(factory_name, *args)
    model = FactoryGirl.build(factory_name, *args)
    if !model.save
      raise SaveError, "Saving factory for :#{factory_name} failed"
    end

    model
  end

  def self.build(factory_name, *args)
    FactoryGirl.build(factory_name, *args)
  end

end