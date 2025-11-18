#Note: A representer is a layer that controls how your data is transformed into JSON or other
#formats before being sent to the client. It plays a similar role to a DTO + serializer in .NET.

class BookRepresenter
    def initialize(book)
        @book = book
    end

    def as_json
        {
            id: book.id,
            title: book.title,
            author_name: author_name(book),
            author_age: book.author&.age
        }
    end

    private

    attr_reader :book

    def author_name(book)
        "#{book.author&.first_name} #{book.author&.last_name}"
    end
end