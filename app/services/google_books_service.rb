require 'json'
require 'open-uri'

class GoogleBooksService
  BASE_URL = 'https://www.googleapis.com/books/v1/volumes'.freeze

  def self.fetch_book_data_by_isbn(isbn)
    api_key = Rails.application.credentials.google_books_api_key
    url = "#{BASE_URL}?q=isbn:#{isbn}&key=#{api_key}"

    begin
      response = URI.open(url).read
      data = JSON.parse(response)

      if data['totalItems'] > 0
        volume_info = data['items'].first['volumeInfo']
        {
          title: volume_info['title'],
          description: volume_info['description'],
          average_rating: volume_info['averageRating'],
          ratings_count: volume_info['ratingsCount'],
          published_date: volume_info['publishedDate']
          # You can extract more fields as needed
        }
      else
        nil # Book not found
      end
    rescue OpenURI::HTTPError => e
      Rails.logger.error "Google Books API error for ISBN #{isbn}: #{e.message}"
      nil
    rescue JSON::ParserError => e
      Rails.logger.error "Google Books API JSON parsing error for ISBN #{isbn}: #{e.message}"
      nil
    rescue StandardError => e
      Rails.logger.error "Unexpected error fetching book data for ISBN #{isbn}: #{e.message}"
      nil
    end
  end
end