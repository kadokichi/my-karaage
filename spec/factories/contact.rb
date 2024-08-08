FactoryBot.define do
  factory :contact do
    name { "Test User" }
    email { "test@example.com" }
    subject { "Test Subject" }
    message { "This is a test message." }
  end
end
