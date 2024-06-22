# frozen_string_literal: true

# rubocop: disable Metrics/BlockLength
FactoryBot.define do
  factory :person_name, class: Yamfrpg::Engine::PersonName do
    given_name { Faker::Name.first_name.gsub(' ', '') }
    surname { Faker::Name.last_name.gsub(' ', '') }
    style { PersonNameFactoryHelper.new.style }

    trait :given_first_surname do
      middle_name { nil }
      suffix { nil }
      style { :given_name_first }
    end

    trait :given_first_suffix do
      middle_name { nil }
      suffix { Faker::Name.suffix }
    end

    trait :given_first_full do
      middle_name { Faker::Name.middle_name.gsub(' ', '') }
      suffix { nil }
      style { :given_name_first }
    end

    trait :given_first_full_suffix do
      middle_name { Faker::Name.middle_name.gsub(' ', '') }
      suffix { Faker::Name.suffix }
      style { :given_name_first }
    end

    trait :surname_first_given do
      middle_name { nil }
      suffix { nil }
      style { :surname_first }
    end

    trait :surname_first_suffix do
      middle_name { nil }
      suffix { Faker::Name.suffix }
      style { :surname_first }
    end

    trait :surname_first_full do
      middle_name { Faker::Name.middle_name.gsub(' ', '') }
      suffix { nil }
      style { :surname_first }
    end

    trait :surname_first_full_suffix do
      middle_name { Faker::Name.middle_name.gsub(' ', '') }
      suffix { Faker::Name.suffix }
      style { :surname_first }
    end
  end
end
# rubocop: enable Metrics/BlockLength

# Helper class for the person name factory.
class PersonNameFactoryHelper
  def style
    idx = Faker::Number.between(from: 0, to: Yamfrpg::Engine::PersonName.styles.length - 1)
    Yamfrpg::Engine::PersonName.styles.keys[idx]
  end
end
