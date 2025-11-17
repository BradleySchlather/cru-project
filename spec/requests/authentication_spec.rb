#NOTE: Requests test the full HTTP request/response cycle

require 'rails_helper'

describe 'Authentication', type: :request do
  describe 'POST /authenticate' do
    #let is an Rspec helper to define a memoized variable. :user is the name of the variable.
    #FactoryBot is a library for creating test objects. .create builds the object and saves it to the db.
    let(:user) { FactoryBot.create(:user, username: 'BookSeller99', password: 'Password1') }

    it 'authenticates the client and returns a valid token' do
      post '/api/v1/authenticate', params: { username: user.username, password: 'Password1' }

      expect(response).to have_http_status(:created)
      expect(response_body['token']).to be_present

      user_id = AuthenticationTokenService.decode(response_body['token'])
      expect(user_id).to eq(user.id)
    end

    it 'returns error when username is missing' do
        post '/api/v1/authenticate', params: { password: 'Password1' }

        expect(response).to have_http_status(:unprocessable_content)
        expect(response_body).to eq({
            'error' => 'param is missing or the value is empty or invalid: username'
        })
    end

    it 'returns error when password is missing' do
        post '/api/v1/authenticate', params: { username: 'BookSeller99' }

        expect(response).to have_http_status(:unprocessable_content)
        expect(response_body).to eq({
            'error' => 'param is missing or the value is empty or invalid: password'
        })
    end

    it 'returns error when password is incorrect' do
      post '/api/v1/authenticate', params: { username: user.username, password: 'WrongPassword1' }

      expect(response).to have_http_status(:unauthorized)
      expect(response_body).to eq({
        'error' => 'Invalid username or password'
      })
    end
  end
end
