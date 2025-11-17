#NOTE: Controllers handle the incoming HTTP requests

module Api
  module V1
    class UsersController < ApplicationController
      def create
        #Creates a user object with the parameters allowed by user_params. This is only in memory at this point.
        user = User.new(user_params)

        #user.save attempts to write the user to the database and it also runs any validations defined in the User model
        if user.save
          #Sends back a JSON response with the new user's id and username with a 201 created
          render json: { id: user.id, username: user.username }, status: :created
        else
          #If user.save fails, sends JSON response that contains readable error messages and a 422 response, meaning the data was invalid
          render json: { errors: user.errors.full_messages }, status: :unprocessable_content
        end
      end

      private

      def user_params
        #Looks for a user in the incoming request. If no user, Rails raises ActionController::ParameterMissing
        #.permit whitelists only username and password fields
        params.require(:user).permit(:username, :password)
      end
    end
  end
end
