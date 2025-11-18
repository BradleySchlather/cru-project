#NOTE: Models represent your data and business logic, backed by ActiveRecord ORM
class User < ApplicationRecord
    #Adds password handling to the model. Requires a password_digest column in the users table. Automatically
    #hashes the password using BCrypt. Handles password and password_confirmation attributes
    has_secure_password

    #username cannot be blank and username has to be unique
    validates :username, presence: true, uniqueness: true
end
