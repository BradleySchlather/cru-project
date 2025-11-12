require 'rails_helper'

describe 'Books API', type: :request do

    let!(:user) { FactoryBot.create(:user, username: 'BookSeller99', password: 'Password1') }

    describe 'GET /books' do
        let!(:first_author) { FactoryBot.create(:author, first_name: 'George', last_name: 'Orwell', age: 46) }
        let!(:second_author) { FactoryBot.create(:author, first_name: 'H.G.', last_name: 'Wells', age: 78) }
        
        before do
            FactoryBot.create(:book, title: '1984', author: first_author)
            FactoryBot.create(:book, title: 'The Great Gatsby', author: second_author)
        end

        it 'returns all books' do
            get '/api/v1/books'
    
            expect(response).to have_http_status(:success)
            expect(response_body.size).to eq(2)

            mapped_books = response_body.map { |b| b.slice('title', 'author_name', 'author_age') }

            expected_books = [
                { 
                    'title' => '1984',
                    'author_name' => 'George Orwell',
                    'author_age' => 46 
                },
                { 
                    'title' => 'The Great Gatsby',
                    'author_name' => 'H.G. Wells',
                    'author_age' => 78 
                }
            ]
            expect(mapped_books).to eq(expected_books)
        end

        it 'returns a subset of books based on pagination' do
            get '/api/v1/books', params: { limit: 1 }

            expect(response).to have_http_status(:success)
            expect(response_body.size).to eq(1)
            expect(response_body.first).to include(
                { 
                    'title' => '1984',
                    'author_name' => 'George Orwell',
                    'author_age' => 46 
                }
            )
        end

        it 'returns a subset of books based on limit and offset' do
            get '/api/v1/books', params: { limit: 1, offset: 1 }

            expect(response).to have_http_status(:success)
            expect(response_body.size).to eq(1)
            expect(response_body.first).to include(
                { 
                    'title' => 'The Great Gatsby',
                    'author_name' => 'H.G. Wells',
                    'author_age' => 78 
                }
            )
        end
    end

    describe 'GET /books/:id' do
        let!(:author) { FactoryBot.create(:author, first_name: 'Aldous', last_name: 'Huxley', age: 69) }
        let!(:book) { FactoryBot.create(:book, title: 'Brave New World', author: author) }

        it 'returns a single book by id' do
            get "/api/v1/books/#{book.id}"

            expect(response).to have_http_status(:ok)
            expect(response_body).to include(
            'title' => 'Brave New World',
            'author_name' => 'Aldous Huxley',
            'author_age' => 69
            )
        end

        it 'returns 404 if the book is not found' do
            get "/api/v1/books/999999"

            expect(response).to have_http_status(:not_found)
            expect(response_body).to eq({ 'error' => 'Book not found' })
        end
    end

    describe 'POST /books' do
        it 'creates a new book' do
            expect {
                post '/api/v1/books', params: {
                    book: { title: 'The Martian' },
                    author: {first_name: 'Andy', last_name: 'Weir', age: '48'}
                }, headers: { "Authorization" => "Bearer #{AuthenticationTokenService.encode(user.id)}" }
            }.to change { Book.count }.from(0).to(1)

            expect(response).to have_http_status(:created)
            expect(Author.count).to eq(1)

            expect(response_body).to include(
                {
                    'title' => 'The Martian',
                    'author_name' => 'Andy Weir',
                    'author_age' => 48
                }
            )
        end
        context 'missing authorization header' do
            it 'returns a 401' do
                post '/api/v1/books', params: {}, headers: {}

                expect(response).to have_http_status(:unauthorized)
            end
        end
    end

    describe 'PATCH /books/:id' do
        let!(:author) { FactoryBot.create(:author, first_name: 'George', last_name: 'Orwell', age: 46) }
        let!(:book) { FactoryBot.create(:book, title: '1984', author: author) }

        it 'updates an existing book and its author' do
            patch "/api/v1/books/#{book.id}",
            params: {
                book: { title: '1984 (Updated Edition)' },
                author: { age: 47 }
            },
            headers: { "Authorization" => "Bearer #{AuthenticationTokenService.encode(user.id)}" }

            expect(response).to have_http_status(:ok)

            expect(response_body).to include(
            'title' => '1984 (Updated Edition)',
            'author_name' => 'George Orwell',
            'author_age' => 47
            )

            expect(book.reload.title).to eq('1984 (Updated Edition)')
            expect(book.author.age).to eq(47)
        end

        it 'returns unauthorized without a valid token' do
            patch "/api/v1/books/#{book.id}",
            params: { book: { title: 'Unauthorized Edit' } },
            headers: {}

            expect(response).to have_http_status(:unauthorized)
        end
    end

    describe 'DELETE /books/:id' do
        let!(:author) { FactoryBot.create(:author, first_name: 'George', last_name: 'Orwell', age: 46) }
        let!(:book) { FactoryBot.create(:book, title: '1984', author: author) }
        it 'deletes a book' do
            expect {
                delete "/api/v1/books/#{book.id}",
                headers: { "Authorization" => "Bearer #{AuthenticationTokenService.encode(user.id)}" }
            }.to change { Book.count }.from(1).to(0)

            expect(response).to have_http_status(:no_content)
        end
    end
end