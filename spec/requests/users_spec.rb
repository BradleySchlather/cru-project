#NOTE: Requests test the full HTTP request/response cycle

require 'rails_helper'

RSpec.describe 'Users API', type: :request do
  describe 'POST /api/v1/users' do
    let(:valid_params) do
      {
        user: {
          username: 'BookSeller99',
          password: 'Password1'
        }
      }
    end

    let(:invalid_params) do
      {
        user: {
          username: '',
          password: 'Password1'
        }
      }
    end

    it 'creates a user with valid parameters' do
      post '/api/v1/users', params: valid_params

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['username']).to eq('BookSeller99')
      expect(json).not_to have_key('password')
    end

    it 'returns error with invalid parameters' do
      post '/api/v1/users', params: invalid_params

      expect(response).to have_http_status(:unprocessable_content)
      json = JSON.parse(response.body)
      expect(json['errors']).to include("Username can't be blank")
    end
  end
end