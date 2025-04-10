class Like < ApplicationRecord
  belongs_to :user
  belongs_to :wordbook, counter_cache: true
end
