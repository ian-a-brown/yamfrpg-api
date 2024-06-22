# frozen_string_literal: true

FactoryBot.define do
  factory :game_master, class: Yamfrpg::Engine::GameMaster do
    association :game, strategy: :create
    association :user_role, factory: %i[user_role game_master], strategy: :create

    after(:build) do |game_master|
      game_master.owner = game_master.game.game_masters.where(owner: true).none?
    end
  end
end
