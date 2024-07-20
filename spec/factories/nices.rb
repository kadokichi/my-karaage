FactoryBot.define do
  factory :nice do
    association :user
    association :review
  end
end
