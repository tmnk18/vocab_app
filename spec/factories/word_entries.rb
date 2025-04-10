FactoryBot.define do
  factory :word_entry do
    sequence(:word) { |n| "単語#{n}" }
    sequence(:meaning) { |n| "意味#{n}" }
    sequence(:example_sentence) { |n| "これは単語#{n}の例文です。" }
    association :wordbook
  end
end