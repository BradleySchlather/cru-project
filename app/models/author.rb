#NOTE: Models represent your data and business logic, backed by ActiveRecord ORM

class Author < ApplicationRecord
    has_many :books
end
