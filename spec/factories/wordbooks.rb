FactoryBot.define do
  factory :wordbook do
    sequence(:title) { |n| "単語帳#{n}" }
    sequence(:description) { |n| "テスト用の単語帳#{n}です" }
    is_public { false }
    association :folder
  end
end