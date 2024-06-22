# frozen_string_literal: true

FactoryBot.define do
  factory :game, class: Yamfrpg::Engine::Game do
    sequence(:game_name) { |n| "Game #{n + 1}" }
  end
end
