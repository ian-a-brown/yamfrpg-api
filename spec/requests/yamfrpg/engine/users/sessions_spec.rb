# frozen_string_literal: true

require 'rails_helper'

# rubocop: disable Metrics/BlockLength
# Specification test for YAMFRPG user sessions.
RSpec.describe Yamfrpg::Engine::Users::SessionsController, type: :request do
  describe 'user login' do
    let(:password) { 'P@ssw0rd!' }
    let(:uuid) { 'uuid' }
    let!(:user) { create(:user, :administrator, password:, password_confirmation: password) }

    context 'no such email address' do
      before(:each) do
        post '/users/sign_in',
             params: { user_login: { email: 'not-a-user@example.com', password: 'password', uuid: } }
      end

      it do
        expect(response).to have_http_status(:unauthorized), "#{response.status}: #{json}"
        expect(json['success']).to be_falsey
        message = json['message'].upcase
        expect(message).to include('ERROR')
        expect(message).to include('EMAIL')
      end
    end

    context 'wrong password' do
      before(:each) do
        post '/users/sign_in',
             params: { user_login: { email: user.email, password: 'password', uuid: } }
      end

      it do
        expect(response).to have_http_status(:unauthorized), "#{response.status}: #{json}"
        expect(json['success']).to be_falsey
        message = json['message'].upcase
        expect(message).to include('ERROR')
        expect(message).to include('PASSWORD')
      end
    end

    context 'existing session for the UUID' do
      let!(:login_session) { create(:login_session, user:, uuid:) }

      before(:each) do
        post '/users/sign_in',
             params: { user_login: { email: user.email, password:, uuid: } }
      end

      it do
        expect(response).to have_http_status(:unauthorized), "#{response.status}: #{json}"
        expect(json['success']).to be_falsey
        expect(json['message'].upcase).to include('ALREADY LOGGED IN')
      end
    end

    context 'valid credentials' do
      before(:each) do
        post '/users/sign_in',
             params: { user_login: { email: user.email, password:, uuid: } }
      end

      it do
        expect(response).to have_http_status(:ok), "#{response.status}: #{json}"
        expect(json['success']).to be_truthy
        expect(json['user_id']).to eq(user.id)
        expect(json['email']).to eq(user.email)
        login_session = Yamfrpg::Engine::LoginSession.find_by(user:, uuid:)
        expect(login_session).to_not be_nil
        expect(json['token']).to eq(login_session.token)
        expect(json['uuid']).to eq(uuid)
      end
    end
  end

  describe 'user logout' do
    let!(:user) { create(:user, :administrator) }
    let(:token) { 'token' }
    let(:uuid) { 'uuid' }

    context 'not logged in' do
      before(:each) do
        delete '/users/sign_out',
               headers: {
                 'X-User-Email': user.email,
                 'X-User-Authentication-Token': token,
                 'X-User-Authentication-Uuid': uuid
               }
      end

      it do
        expect(response).to have_http_status(422), "#{response.status}: #{json}"
        expect(json['message']).to include('No login session')
      end
    end

    context 'logged in' do
      let!(:login_session) { create(:login_session, user:, uuid:, token:) }

      context 'expired token' do
        before(:each) do
          login_session.update!(expires: 1.minute.ago)
          delete '/users/sign_out',
                 headers: {
                   'X-User-Email': user.email,
                   'X-User-Authentication-Token': token,
                   'X-User-Authentication-Uuid': uuid
                 }
        end

        it do
          expect(response).to have_http_status(422), "#{response.status}: #{json}"
          expect(json['message']).to include('expired')
          expect(Yamfrpg::Engine::LoginSession.find_by(id: login_session.id)).to be_nil
        end
      end

      context 'valid token' do
        before(:each) do
          delete '/users/sign_out',
                 headers: {
                   'X-User-Email': user.email,
                   'X-User-Authentication-Token': token,
                   'X-User-Authentication-Uuid': uuid
                 }
        end

        it do
          expect(response).to have_http_status(:ok), "#{response.status}: #{json}"
          expect(json['success']).to be_truthy
        end
      end
    end
  end
end
# rubocop: enable Metrics/BlockLength
