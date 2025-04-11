FactoryBot.define do
  factory :wordbook do
    sequence(:title) { |n| "単語帳#{n}" }
    sequence(:description) { |n| "テスト用の単語帳#{n}です" }
    is_public { false }
    association :folder

    # 公開状態の単語帳を作成するトレイト
    trait :public do
      is_public { true }
    end

    # 単語が登録された状態の単語帳を作成するトレイト
    trait :with_words do
      after(:create) do |wordbook|
        create_list(:word_entry, 3, wordbook: wordbook)
      end
    end

    # 説明文なしの単語帳を作成するトレイト
    trait :without_description do
      description { nil }
    end
  end
end