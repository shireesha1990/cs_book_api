class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError
  queue_as :default

  def perform(book_id)
    book = Book.find_by(id: book_id)
    return unless book && book.isbn.present?

    book_data = GoogleBooksService.fetch_book_data_by_isbn(book.isbn)

    if book_data && book_data[:average_rating].present?
      book.update(rating: book_data[:average_rating])
      Rails.logger.info "Successfully fetched and updated rating for Book ID #{book.id} (ISBN: #{book.isbn})"
    else
      Rails.logger.warn "Could not fetch rating for Book ID #{book.id} (ISBN: #{book.isbn}). Book data: #{book_data.inspect}"
    end
  rescue StandardError => e
    Rails.logger.error "Error in BookRatingFetcherJob for Book ID #{book_id}: #{e.message}"
  end
end
