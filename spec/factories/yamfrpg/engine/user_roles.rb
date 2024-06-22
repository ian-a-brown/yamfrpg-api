# frozen_string_literal: true

FactoryBot.define do
  factory :user_role, class: Yamfrpg::Engine::UserRole do
    association :user, strategy: :create

    role { UserRoleFactoryHelper.new.role }

    trait :administrator do
      role { :administrator }
    end

    trait :game_master do
      role { :game_master }
    end

    trait :player do
      role { :player }
    end
  end
end

# Helper class for the user role factory.
class UserRoleFactoryHelper
  def role
    idx = Faker::Number.between(from: 0, to: Yamfrpg::Engine::UserRole.roles.length - 1)
    Yamfrpg::Engine::UserRole.roles.keys[idx]
  end
end
