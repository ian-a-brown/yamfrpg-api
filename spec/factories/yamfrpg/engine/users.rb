# frozen_string_literal: true

# rubocop: disable Metrics/BlockLength
FactoryBot.define do
  factory :user, class: Yamfrpg::Engine::User do
    association :address, strategy: :create
    association :person_name, strategy: :create

    email { Faker::Internet.email }
    password { 'P@ssw0rd!' }
    password_confirmation { 'P@ssw0rd!' }

    trait :administrator do
      after(:build) do |user, _|
        unless user.user_roles.find_by(role: :administrator).present?
          user.user_roles << build(:user_role,
                                   user:,
                                   role: :administrator)
        end
      end
    end

    trait :game_master do
      after(:build) do |user, _|
        unless user.user_roles.find_by(role: :game_master).present?
          user.user_roles << build(:user_role,
                                   user:,
                                   role: :game_master)
        end
      end
    end

    trait :player do
      after(:build) do |user, _|
        unless user.user_roles.find_by(role: :player).present?
          user.user_roles << build(:user_role,
                                   user:,
                                   role: :player)
        end
      end
    end
  end
end
# rubocop: enable Metrics/BlockLength
