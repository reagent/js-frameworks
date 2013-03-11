require 'factory_girl'

FactoryGirl.define do
  to_create do |instance|
    if !instance.save
      raise "Save failed for #{instance.class}"
    end
  end

  factory :user do
    sequence(:email)      {|n| "user_#{n}@host.com" }
    sequence(:username)   {|n| "username_#{n}" }
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

Factory = FactoryGirl