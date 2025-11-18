#NOTE: Models represent your data and business logic, backed by ActiveRecord ORM
class User < ApplicationRecord
    has_secure_password

    validates :username, presence: true, uniqueness: true
end
