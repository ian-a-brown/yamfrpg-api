# frozen_string_literal: true

FactoryBot.define do
  factory :user_phone_number, class: Yamfrpg::Engine::UserPhoneNumber do
    association :phone_number, strategy: :create
    association :user, strategy: :create

    kind { UserPhoneNumberFactoryHelper.new.kind }
  end
end

# Helper class for the user phone number factory.
class UserPhoneNumberFactoryHelper
  def kind
    idx = Faker::Number.between(from: 0, to: Yamfrpg::Engine::UserPhoneNumber.kinds.length - 1)
    Yamfrpg::Engine::UserPhoneNumber.kinds.keys[idx]
  end
end
