#NOTE: This controller spec tests the behavior of a single controller action in isolation

#Loads the rails test environment
require "rails_helper"

#Describes the BooksController in the Api::V1 namespace
RSpec.describe Api::V1::BooksController, type: :controller do
    #Starts a group of tests for the index action of your BooksController
    describe 'GET index' do
        #Test to ensure that even if the client requests 999 for the limit, the controller still enforces max of 100
        it 'has a max limit of 100' do
            #Sets an expectation on the Book model. Book should receive the limit method call, which should be called with the argument 100
            #.and_call_original ensures that after verifying the method was called, the real Book.limi method still executes
            expect(Book).to receive(:limit).with(100).and_call_original
            #Simulates an HTTP GET request to the index action with 999 as the parameter value
            get :index, params: { limit: 999 }
        end
    end

    describe 'POST create' do
        context 'missing authorization header' do
            it 'returns a 401' do
                #This works without params because we are checking authentication prior to checking the params
                post :create, params: {}
                expect(response).to have_http_status(:unauthorized)
            end
        end
    end

    describe 'PATCH update' do
        context 'missing authorization header' do
            it 'returns a 401' do
                patch :update, params: { id: 1 }
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