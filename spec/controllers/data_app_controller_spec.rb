require 'rails_helper'

RSpec.describe DataAppController, type: :request do
  let(:admin) { create(:user, first_name: 'Admin') }
  let(:owner) {create(:user, first_name: 'Owner')}
  let(:other) { create(:user, first_name: 'Other') }
  let(:test_nilm) { create(:nilm, name: "Test NILM", admins: [admin], owners: [owner]) }
  let(:test_app) { create(:data_app, name: "Test App", nilm: test_nilm)}
  let(:other_app) { create(:data_app, name: "Other App", nilm: test_nilm)}

  describe 'GET show' do
    context 'with any permissions' do
      it 'returns the data_app as json' do
        @auth_headers = owner.create_new_auth_token
        get "/app/#{test_app.id}.json",
            headers: @auth_headers
        expect(response.status).to eq(200)
        expect(response.header['Content-Type']).to include('application/json')
        body = JSON.parse(response.body)
        expect(body["name"]).to eq test_app.name
        # no URL if not proxied
        expect(body["url"]).to eq '#'
        expect(InterfaceAuthToken.count).to eq 0
      end
      it 'returns url if proxied' do
        @auth_headers = owner.create_new_auth_token
        get "/app/#{test_app.id}.json",
            headers: @auth_headers.merge({HTTP_X_APP_BASE_URI:'/lumen'})
        expect(response.status).to eq(200)
        expect(response.header['Content-Type']).to include('application/json')
        body = JSON.parse(response.body)
        expect(body["name"]).to eq test_app.name
        # URL has an auth token
        token = InterfaceAuthToken.where(data_app:test_app).first
        expect(body["url"]).to end_with token.value
      end
    end
    context 'without permissions' do
      it 'returns unauthorized' do
        @auth_headers = other.create_new_auth_token
        get "/app/#{test_app.id}.json",
            headers: @auth_headers
        expect(response.status).to eq(401)
        expect(InterfaceAuthToken.count).to eq 0
      end
    end
    context 'without sign-in' do
      it 'returns unauthorized' do
        #  no headers: nobody is signed in, deny all
        get "/app/#{test_app.id}.json"
        expect(response.status).to eq(401)
        expect(InterfaceAuthToken.count).to eq 0
      end
    end
  end
end
