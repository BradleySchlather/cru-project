#Note: A service is a Ruby class that encapsulates business logic that doesn’t belong in a model or controller

#This service contains the logic for encoding and decoding the JWT
class AuthenticationTokenService
    #Constant variable of the JWT secret key, which we get from the .env file. This doesn't get pushed to github because
    #we included /.env* to the github file.
    JWT_SECRET_KEY = ENV.fetch('JWT_SECRET_KEY')
    #Constant var of the algorithm type
    ALGORITHM_TYPE = 'HS256'

    #Using self makes this a class method. Without self it would be an instance method, which would require me to make an object of it first
    def self.encode(user_id)
        #Creates a payload object of the subject, issued at = timestamp of now, and expiration
        #Time.now.to_i converts the time object to an integer that represents seconds since the Unix epoch
        payload = {sub: user_id, iat: Time.now.to_i, exp: 1.hour.from_now.to_i}
        
        #JWT.encode comes from the JWT gem. Parentheses are optional in ruby when using methods.
        JWT.encode payload, JWT_SECRET_KEY, ALGORITHM_TYPE
    end

    #Self makes this a class method
    def self.decode(token)
        #This will decode the token using the JWT gem and assign the payload and header. _ is used to show we aren't going to use it
        payload, _header = JWT.decode(token, JWT_SECRET_KEY, true, { algorithm: ALGORITHM_TYPE })

        #Returns the subject from the payload
        payload['sub']
        #This catches a decode error or an expired signature, both of which return nil.
    rescue JWT::DecodeError, JWT::ExpiredSignature
        #We return nil because we don't want to expose any sensitive details
        nil
    end
end