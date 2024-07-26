FactoryBot.define do
  factory :review do
    content { 'Test review content' }
    score { 5 }
    association :user
    association :shop
  end
end
