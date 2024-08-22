FactoryBot.define do
  factory :user do
    name { "Test User" }
    email { "test@example.com" }
    password { "password" }
    password_confirmation { "password" }
  end

  factory :another_user, class: 'User' do
    name { "Another Test User" }
    email { "another_test@example.com" }
    password { "password" }
    password_confirmation { "password" }
  end

  factory :guest_user, class: 'User' do
    name { "ゲスト" }
    email { "guest@example.com" }
    password { "password" }
    password_confirmation { "password" }
  end

  factory :click_user, class: 'User' do
    sequence(:name) { |n| "Click User #{n}" }
    sequence(:email) { |n| "clickuser#{n}@example.com" }
    password { "password" }
    password_confirmation { "password" }
  end
end
