class BooksController < ApplicationController
  before_action :set_book, only: [:show, :update, :destroy]

  # GET /books - List all books, or filter by category
  def index
      @books = Book.all
    render json: @books, include: :author
  end

  # GET /books/1 - Show a specific book
  def show
    render json: @book, include: :author
  end

  # POST /books - Create a new book
  def create
    author = Author.find_or_create_by!(name: book_params[:author_name]) do |a|
      a.biography = book_params[:author_biography]
    end

    @book = author.books.new(book_params.except(:author_name, :author_biography))

    if @book.save
      render json: @book, status: :created, location: @book, include: :author
    else
      render json: @book.errors, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  # PATCH/PUT /books/1 - Update an existing book
  def update
    if @book.update(book_params.except(:author_name, :author_biography))
      render json: @book, include: :author
    else
      render json: @book.errors, status: :unprocessable_entity
    end
  end

  # DELETE /books/1 - Delete a book
  def destroy
    @book.destroy
    head :no_content
  end

  private
    def set_book
      @book = Book.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'Book not found' }, status: :not_found
    end

    def book_params
      params.require(:book).permit(:title, :description, :isbn, :author_id, :author_name, :author_biography)
    end
end