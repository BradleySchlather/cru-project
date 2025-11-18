#NOTE: Models represent your data and business logic, backed by ActiveRecord ORM

class Book < ApplicationRecord
    validates :title, presence: true, length: { minimum: 3 }

    #Sets up a one to many relationship, so each book should have exactly one author. Rails now expects to have an
    #author_id in the books table, but it won't do it automatically. For that we have to create a migration, which we did (add_author_to_books)
    belongs_to :author
end
