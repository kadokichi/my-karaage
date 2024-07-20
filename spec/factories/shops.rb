FactoryBot.define do
  factory :shop do
    name { "Test Shop" }
    address { "123 Test St" }
    taste { "Test Flavor" }
    price { "300" }
    description { "Test Description 123" }
    product_name { "Test Product" }
    likes_count { 0 }
    association :user
  end
end
