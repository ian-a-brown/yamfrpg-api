# frozen_string_literal: true

FactoryBot.define do
  factory :address, class: Yamfrpg::Engine::Address do
    address_one { Faker::Address.street_address }
    address_two { Faker::Address.secondary_address }
    city { Faker::Address.city }
    region { Faker::Address.state }
    country { 'US' }
    postal_code { Faker::Address.postcode }
  end
end
