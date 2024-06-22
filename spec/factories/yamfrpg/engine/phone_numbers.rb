# frozen_string_literal: true

FactoryBot.define do
  factory :phone_number, class: Yamfrpg::Engine::PhoneNumber do
    number { Faker::PhoneNumber.phone_number }
  end
end
