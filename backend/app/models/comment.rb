class Comment < ApplicationRecord
  belongs_to :article, counter_cache: true

  validates :body, presence: true
  validates :author_name, presence: true, length: { maximum: 100 }
end
