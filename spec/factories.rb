# This will guess the User class
FactoryGirl.define do
  factory :user do
    email "teacplusplus@gmail.com"
    name  "tea"
    role 2
  end

  factory :advertisement do
    offer_type :sale
    category :flat
    property_type :residental
    name 'Сдам однушку'
    phone '891912332122'
    price_from 100
    adv_type 0
    sales_agent 'test agent'
    user
  end

  factory :abuse do
    advertisement_id 1
    comment 'WTF'
    abuse_type 0
  end
end