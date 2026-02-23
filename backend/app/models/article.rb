class Article < ApplicationRecord
  has_many :comments, dependent: :destroy

  validates :title, presence: true, length: { maximum: 200 }
  validates :body, presence: true
  validates :author_name, presence: true, length: { maximum: 100 }
end
