FactoryBot.define do
  factory :shop do
    name { "Test Shop" }
    address { "123 Test St" }
    taste { "濃い味系" }
    price { 300 }
    description { "Test Description 123" }
    product_name { "Test Product" }
    shop_url { "www.test.com" }
  end

  factory :shop2, class: 'Shop' do
    name { "テストショップ" }
    address { "大阪府大阪市中央区大阪城１−１" }
    taste { "濃い味系" }
    price { 300 }
    description { "Test Description 123" }
    product_name { "Test Product" }
    shop_url { "https://www.osakacastle.net/" }
  end

  factory :shop3, class: 'Shop' do
    name { "東京唐揚げ" }
    address { "東京都港区芝公園４丁目２−８" }
    taste { "あっさり系" }
    price { 300 }
    description { "Test Description 123" }
    product_name { "Test Product" }
  end

  factory :shop4, class: 'Shop' do
    name { "Another Test ショップ" }
    address { "Test St 123" }
    taste { "あっさり系" }
    price { 300 }
    description { "Test Description 123" }
    product_name { "Test Product" }
  end

  factory :shop5, class: 'Shop' do
    name { "Test Store" }
    address { "Test St 12345" }
    taste { "濃い味系" }
    price { 300 }
    description { "Test Description 12345" }
    product_name { "Test Product" }
  end
end
