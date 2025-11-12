module Api
  module V1

    class BooksController < ApplicationController
      include ActionController::HttpAuthentication::Token

      MAX_PAGINATION_LIMIT = 100

      before_action :authenticate_user, only: [:create, :update, :destroy]

      def index
        books = Book.limit(limit).offset(params[:offset])
        render json: BooksRepresenter.new(books).as_json
      end

      def show
        book = Book.find(params[:id])
        render json: BookRepresenter.new(book).as_json, status: :ok
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Book not found" }, status: :not_found
      end

      def create
        author = Author.create!(author_params)
        book = Book.new(book_params.merge(author_id: author.id))

        if book.save
          render json: BookRepresenter.new(book).as_json, status: :created
        else
          render json: book.errors, status: :unprocessable_content
        end
      end

      def update
        book = Book.find(params[:id])
        author = book.author

        if book.update(book_params) && author.update(author_params)
          render json: BookRepresenter.new(book).as_json, status: :ok
        else
          render json: { errors: book.errors.full_messages + author.errors.full_messages },
                status: :unprocessable_content
        end
      end

      def destroy
        Book.find(params[:id]).destroy!

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

      def author_params
        params.require(:author).permit(:first_name, :last_name, :age)
      end

      def book_params
        params.require(:book).permit(:title)
      end
    end
  end
end