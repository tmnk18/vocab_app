FactoryBot.define do
  factory :folder do
    sequence(:name) { |n| "フォルダ#{n}" }
    association :user
  end
end