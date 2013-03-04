require 'factory_girl'

FactoryGirl.define do
  factory :user do
    sequence(:email) {|n| "user_#{n}@host.com" }
    password         'sekrit'
  end
end