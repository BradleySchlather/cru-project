require 'rails_helper'

describe AuthenticationTokenService do
  describe '.encode' do
    let(:user_id) { 1 }
    let(:token) { described_class.encode(user_id) }

    it 'returns a valid JWT token' do
      payload, header = JWT.decode(
        token,
        described_class::JWT_SECRET_KEY,
        true,
        { algorithm: described_class::ALGORITHM_TYPE }
      )

      expect(payload['sub']).to eq(user_id)
      expect(payload['iat']).to be_present
      expect(payload['exp']).to be_present

      expect(header['alg']).to eq(described_class::ALGORITHM_TYPE)
    end
  end

  describe '.decode' do
    it 'returns the original user_id from the token' do
      user_id = 42
      token = described_class.encode(user_id)

      decoded_user_id = described_class.decode(token)
      expect(decoded_user_id).to eq(user_id)
    end
  end
end
