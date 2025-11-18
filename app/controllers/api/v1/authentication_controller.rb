#NOTE: Controllers handle the incoming HTTP requests

module Api
  module V1
    class AuthenticationController < ApplicationController
      class AuthenticationError < StandardError; end

      #Error class raised when client has a parameter missing. The parameter_missing(e) will be called
      rescue_from ActionController::ParameterMissing, with: :parameter_missing
      #Comes from the custom class above. Will trigger the handle_unauthenticated method
      rescue_from AuthenticationError, with: :handle_unauthenticated

    def create
        #Requires the client to pass username and password
        username = params.require(:username)
        password = params.require(:password)

        #User is the model. find_by is an ActiveRecord method that queries the database for the first record matching the given condition
        user = User.find_by(username: username)
        #Will use the custom class if not authenticated. & is the safe navigation operator. It will only call the method if the user object is not null
        raise AuthenticationError unless user&.authenticate(password)

        #Uses the auth token service to encode the user id, which will lead to the jwt being created
        token = AuthenticationTokenService.encode(user.id)
        #render sends a response back to the client. So, a token gets sent back to the client in json and a 201 response will be given
        render json: { token: token }, status: :created
    end

    #access modifier only allows for being called in this controller
      private

      
      def user
        #@user is an instance variable tied to this controller instance
        #||= is called the memoization operator
        #If @user already has a value, then return it. If user is nil or falsey, evaluate the right hand side and assign it
        @user ||= User.find_by(username: params.require(:username))
      end

      def parameter_missing(e)
        #Sends JSON error message and 422 response. 422 means the server understood the request but the data was invalid
        render json: { error: e.message }, status: :unprocessable_content
      end

      def handle_unauthenticated
        #Triggered by custom class. Returns json error message and 401 unauthorized
        render json: { error: 'Invalid username or password' }, status: :unauthorized
      end
    end
  end
end