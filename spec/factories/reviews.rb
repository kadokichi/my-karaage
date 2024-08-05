FactoryBot.define do
  factory :review do
    content { "Test review content" }
    score { 3 }
    association :user
    association :shop
  end

  factory :another_review, class: 'Review' do
    content { "Test another review content" }
    score { 4 }
    association :user
    association :shop
  end
end
