# This will guess the User class
FactoryGirl.define do
  factory :user do
    email "teacplusplus@gmail.com"
    name  "tea"
    role 2
  end

  factory :advertisement do
    offer_type 1
    category 1
    property_type 1
    name 'Сдам однушку'
    phone '891912332122'
    price_from 100
    adv_type 0
    sales_agent 'test agent'
  end
end