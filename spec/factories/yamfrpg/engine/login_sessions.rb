# frozen_string_literal: true

FactoryBot.define do
  factory :login_session, class: Yamfrpg::Engine::LoginSession do
    association :user, strategy: :create
    expires { 3.months.from_now }
    token { SecureRandom.urlsafe_base64(nil, false) }
    uuid { SecureRandom.uuid }
  end
end
