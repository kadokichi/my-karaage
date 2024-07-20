FactoryBot.define do
  factory :user do
    id { "1" }
    name { "Test User" }
    email { "test@example.com" }
    password { "password" }
    password_confirmation { "password" }
  end

  factory :another_user, class: 'User' do
    id { "2" }
    name { "Another Test User" }
    email { "another_test@example.com" }
    password { "password" }
    password_confirmation { "password" }
  end
end
