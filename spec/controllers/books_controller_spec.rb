require "rails_helper"

RSpec.describe Api::V1::BooksController, type: :controller do
    describe 'GET index' do
        it 'has a max limit of 100' do
            expect(Book).to receive(:limit).with(100).and_call_original
            get :index, params: { limit: 999 }
        end
    end

    describe 'POST create' do
        context 'missing authorization header' do
            it 'returns a 401' do
                post :create, params: {}
                expect(response).to have_http_status(:unauthorized)
            end
        end
    end

    describe 'PATCH update' do
        context 'missing authorization header' do
            it 'returns a 401' do
                patch :update, params: { id: 1}
                expect(response).to have_http_status(:unauthorized)
            end
        end
    end

    describe 'DELETE destroy' do
        context 'missing authorization header' do
            it 'returns a 401' do
                delete :destroy, params: { id: 1 }
                expect(response).to have_http_status(:unauthorized)
            end
        end
    end
end