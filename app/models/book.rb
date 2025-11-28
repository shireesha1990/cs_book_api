class Book < ApplicationRecord
  belongs_to :author

  validates :title, presence: true
  validates :isbn, presence: true, uniqueness: true, format: { with: /\A(?:ISBN(?:-13)?:?)(?=[0-9]{13}$)([0-9]{3}-){2}[0-9]{3}[0-9X]$|\A(?:ISBN(?:-10)?:?)(?=[0-9]{10}$)([0-9]{9}[0-9X])$/i, message: "is invalid" }
  validates :description, presence: true, length: { maximum: 2000 }
  validates :category, presence: true

  # Custom validation to ensure category is 'Computer Science' for this specific app's purpose
  validates :category, inclusion: { in: ['Computer Science'], message: "must be 'Computer Science' for this application" }

  # Callback to fetch rating after a book is created or updated
  after_create_commit :fetch_rating_from_google_books
  after_update_commit :fetch_rating_from_google_books, if: :isbn_changed?

  private

  def fetch_rating_from_google_books
    BookRatingFetcherJob.perform_later(self.id)
  end
end