require 'rails_helper'

describe 'Authentication', type: :request do
    HMAC_SECRET = 'my$ecretK3y'
    ALGORITHM_TYPE = 'HS256'
    describe 'POST /authenticate' do
        let(:user) { FactoryBot.create(:user, username: 'BookSeller99', password: 'Password1') }
        it 'authenticates the client' do
            post '/api/v1/authenticate', params: { username: user.username, password: 'Password1' }

            expect(response).to have_http_status(:created)

            decoded_token = JWT.decode(
            response_body['token'],
            HMAC_SECRET,
            true,
            algorithm: ALGORITHM_TYPE
            )
            expect(decoded_token.first['user_id']).to eq(user.id)
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
        end
    end
end