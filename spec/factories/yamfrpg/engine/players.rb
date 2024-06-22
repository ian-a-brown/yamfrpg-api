# frozen_string_literal: true

FactoryBot.define do
  factory :player, class: Yamfrpg::Engine::Player do
    association :game, strategy: :create
    association :user_role, factory: %i[user_role player], strategy: :create
  end
end
