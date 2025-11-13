class AuthenticationTokenService
    JWT_SECRET_KEY = ENV.fetch('JWT_SECRET_KEY')
    ALGORITHM_TYPE = 'HS256'

    def self.encode(user_id)
        payload = {sub: user_id, iat: Time.now.to_i, exp: 1.hour.from_now.to_i}
        
        JWT.encode payload, JWT_SECRET_KEY, ALGORITHM_TYPE
    end

    def self.decode(token)
        payload, _header = JWT.decode(token, JWT_SECRET_KEY, true, { algorithm: ALGORITHM_TYPE })
        payload['sub']
    rescue JWT::DecodeError, JWT::ExpiredSignature
        nil
    end
end