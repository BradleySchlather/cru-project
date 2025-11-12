module Api
  module V1

    class BooksController < ApplicationController
      include ActionController::HttpAuthentication::Token

      MAX_PAGINATION_LIMIT = 100

      before_action :authenticate_user, only: [:create, :update, :destroy]
      before_action :set_book, only: [:show, :update, :destroy]

      def index
        books = Book.limit(limit).offset(params[:offset])
        render json: BooksRepresenter.new(books).as_json
      end

      def show
        render json: BookRepresenter.new(@book).as_json, status: :ok
      end

      def create
        author = Author.find_or_create_by(author_params)
        book = Book.new(book_params.merge(author: author))

        if book.save
          render json: BookRepresenter.new(book).as_json, status: :created
        else
          render json: book.errors, status: :unprocessable_content
        end
      end

      def update
        ActiveRecord::Base.transaction do
          @book.update!(book_params)
          @book.author.update!(author_params)
        end

        render json: BookRepresenter.new(@book).as_json, status: :ok
      rescue ActiveRecord::RecordInvalid => e
        render json: { errors: e.record.errors.full_messages }, status: :unprocessable_content
      end

      def destroy
        @book.destroy
        head :no_content
      end

      private

      def authenticate_user
        token, _options = token_and_options(request)
        user_id = AuthenticationTokenService.decode(token)
        User.find(user_id)
      rescue ActiveRecord::RecordNotFound, JWT::DecodeError
        render status: :unauthorized
      end

      def limit
        [
          params.fetch(:limit, MAX_PAGINATION_LIMIT).to_i,
          MAX_PAGINATION_LIMIT
        ].min
      end

      def set_book
        @book = Book.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Book not found" }, status: :not_found
      end

      def author_params
        params.require(:author).permit(:first_name, :last_name, :age)
      end

      def book_params
        params.require(:book).permit(:title)
      end
    end
  end
end
