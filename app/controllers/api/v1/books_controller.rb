#NOTE: Controllers handle the incoming HTTP requests

module Api
  module V1

    class BooksController < ApplicationController
      #Gives the controller built in token-authentication helpers
      include ActionController::HttpAuthentication::Token

      #Constant for pagination limit
      MAX_PAGINATION_LIMIT = 100

      #Before action is a rails controller callback. It runs a method before actions are executed. Runs the authenicate_user method
      before_action :authenticate_user, only: [:create, :update, :destroy]
      before_action :set_book, only: [:show, :update, :destroy]

      def index
        #Book is the model representing the books table in the database. .limit restricts the records returned. limit is the method below
        #.offset is used for skipping records. params[:offset] comes from the request.
        books = Book.limit(limit).offset(params[:offset])
        #sends json using booksrepresenter 
        render json: BooksRepresenter.new(books).as_json
      end

      def show
        #Returns one book. The @book is an instance variable. These are available throughout the instance of the controller.
        #The @book is available becuase the second before_action calls the set_book method, which sets the @book variable
        #The status: :ok will send a 200 status code, but it does default to that anyway. Can be useful when wanting to be explicit
        render json: BookRepresenter.new(@book).as_json, status: :ok
      end

      def create
        #Author is the model representing the Author table in the database. .find_or_create_by is a Rails Active Record
        #method that will first try to find the author and if there isn't one it will create one.
        author = Author.find_or_create_by(author_params)
        #Book is the model representing the Book table in the database. The merger will only grab the author's id to be stored in the db
        book = Book.new(book_params.merge(author: author))
        
        #book.save attempts to persists the book object to the db. This will run the validations in the book model
        if book.save
          render json: BookRepresenter.new(book).as_json, status: :created
        #if book.save fails return the errors and status code 422
        else
          render json: book.errors, status: :unprocessable_content
        end
      end

      #PATCH /books/:id
      def update
        #Starts a db transaction. A transaction is where a block of code must succeed together. If any changes fail, they are all rolled back
        ActiveRecord::Base.transaction do
          #Using the @book instance variable that was created in the second before action
          #The .update! raises an exception if validation fails instead of returning false. This is important for transactions
          #because an exception automatically rolls back the transaction.
          @book.update!(book_params)
          @book.author.update!(author_params)
        end

        #Uses the bookrepresenter to send the updated book back to the client
        render json: BookRepresenter.new(@book).as_json, status: :ok
        #If the transaction fails, Rails raises ActiveRecord::RecordInvalid. The rescue block catches the exception
        #and the controller returns a response with all validation errors and status 422
      rescue ActiveRecord::RecordInvalid => e
        render json: { errors: e.record.errors.full_messages }, status: :unprocessable_content
      end

      def destroy
        #Again using the @book instance variable. destroy is an ActiveRecord method that deletes a record from the database.
        @book.destroy
        #head is a Rails controller helper used to send an HTTP response without a body. :no_content corresponds to HTTP status code 204
        head :no_content
      end

      private

      def authenticate_user
        #token_and_options is a helper method provided by include ActionController::HttpAuthentication::Token
        #It extracts the token and any optional parameters from an HTTP Authorization header in the request
        #This is an instance of a parallel assignment, whereby two variables are being assigned at once because an array is being used
        #An _ in Ruby is a used when you don't use the variable
        token, _options = token_and_options(request)
        #Uses the authentication service to decode the token, sending back only the user_id
        user_id = AuthenticationTokenService.decode(token)
        #User is the model, which represents the users table in the db. .find is an ActiveRecord method that retrieves a record by its primary key
        User.find(user_id)
        #If the user is not found or if there is an error decoding the token, return 401
      rescue ActiveRecord::RecordNotFound, JWT::DecodeError
        render status: :unauthorized
      end

      def limit
        #Creates an array that will get the minimum element to ensure it never goes over the pagination limit
        [
          #params.fetch gets the limit from the url query parameters. if not limit is provided, it defaults to the max limit set by the constant
          #.to_i ensures this is a number
          params.fetch(:limit, MAX_PAGINATION_LIMIT).to_i,
          MAX_PAGINATION_LIMIT
        ].min
      end

      def set_book
        #This is where the @book variable is being set. .find is an ActiveRecord method that retrieves a record by its primary key
        @book = Book.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        #If not found return 404
        render json: { error: "Book not found" }, status: :not_found
      end

      def author_params
        #Looks for an author in the incoming request. If author is missing, Rails raises ActionController::ParameterMissing.
        #.permit whitelists only the fields passed in as arguments, ignoring anything else.
        params.require(:author).permit(:first_name, :last_name, :age)
      end

      def book_params
        #Looks for a book in the incoming request. Using .permit again, but only for the title field this time
        params.require(:book).permit(:title)
      end
    end
  end
end
