FactoryBot.define do
  factory :user do
    sequence(:username) do |n|
      "testuser#{n}"
    end
    
    sequence(:email) do |n|
      "test#{n}@example.com"
    end
    
    password { "password" }
    password_confirmation { "password" }

    # アバターの添付が必要な場合のみ
    after(:build) do |user|
      if File.exist?(Rails.root.join('spec', 'fixtures', 'files', 'avatar.jpg'))
        user.avatar.attach(
          io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'avatar.jpg')),
          filename: 'avatar.jpg',
          content_type: 'image/jpeg'
        )
      end
    end
  end
end