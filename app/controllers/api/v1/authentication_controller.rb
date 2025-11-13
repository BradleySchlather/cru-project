module Api
  module V1
    class AuthenticationController < ApplicationController
      class AuthenticationError < StandardError; end

      rescue_from ActionController::ParameterMissing, with: :parameter_missing
      rescue_from AuthenticationError, with: :handle_unauthenticated

    def create
        username = params.require(:username)
        password = params.require(:password)

        user = User.find_by(username: username)
        raise AuthenticationError unless user&.authenticate(password)

        token = AuthenticationTokenService.encode(user.id)
        render json: { token: token }, status: :created
    end

      private

      def user
        @user ||= User.find_by(username: params.require(:username))
      end

      def parameter_missing(e)
        render json: { error: e.message }, status: :unprocessable_content
      end

      def handle_unauthenticated
        render json: { error: 'Invalid username or password' }, status: :unauthorized
      end
    end
  end
end