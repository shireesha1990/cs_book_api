class Author < ApplicationRecord
  has_many :books, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :biography, length: { maximum: 1000 }
end