require 'spec_helper'
require 'faker'
require 'active_support/all'
require 'httparty'

describe TD::Users::Auth do
  let(:response) { double("Response") }
  let(:token) { Faker::Bitcoin.address }
  let(:user_id) { Faker::Lorem.sentence }
  let(:email) { Faker::Internet.email }
  let(:attrs) do
    { user_id: user_id,
      email: email,
      password: Faker::Internet.password,
      remember_me: true,
      verify_token: token }
  end
  let(:error) do
    { code: "ValidationError",
      message: "Field error description",
      errors: [] }
  end
  describe '.sign_up' do
    context 'when server responds with 200' do
      it 'returns the auth with the token' do
        allow(TD::Users::Auth).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(200)
        allow(response).to receive(:body).and_return( { token: token }.to_json)
        auth = TD::Users::Auth.sign_up(attrs)
        expect(auth.token).to eq token
        expect(auth.user_id).to eq attrs[:user_id]
        expect(auth.email).to eq attrs[:email]
      end
    end

    context 'when param is not a hash' do
      it 'raises an InvalidParam exception' do
        expect { TD::Users::Auth.sign_up(Faker::Lorem.word) }.to raise_error TD::Users::InvalidParam
        expect do
          TD::Users::Auth.sign_up(Faker::Number.number(3).to_i)
        end.to raise_error TD::Users::InvalidParam
        expect { TD::Users::Auth.sign_up(Date.today) }.to raise_error TD::Users::InvalidParam
      end
    end

    context 'when server responds with 400' do
      it 'raises a ValidationError exception' do
        allow(TD::Users::Auth).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(400)
        allow(response).to receive(:body).and_return(error.to_json)
        expect { TD::Users::Auth.sign_up(attrs) }.to raise_error TD::Users::ValidationError
      end
    end

    context 'when server responds with 401' do
      it 'raises an AuthFailed exception' do
        allow(TD::Users::Auth).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(401)
        allow(response).to receive(:body).and_return(error.to_json)
        expect { TD::Users::Auth.sign_up(attrs) }.to raise_error TD::Users::AuthFailed
      end
    end

    context 'when server responds with 403' do
      it 'raises an AuthFailed exception' do
        allow(TD::Users::Auth).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(403)
        allow(response).to receive(:body).and_return(error.to_json)
        expect { TD::Users::Auth.sign_up(attrs) }.to raise_error TD::Users::AuthFailed
      end
    end

    context 'when server responds with a 404' do
      it 'raises an AuthFailed exception' do
        allow(TD::Users::Auth).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(404)
        allow(response).to receive(:body).and_return(error.to_json)
        expect { TD::Users::Auth.sign_up(attrs) }.to raise_error TD::Users::AuthFailed
      end
    end

    context 'when server responds with a 409' do
      it 'raises an AuthFailed exception' do
        allow(TD::Users::Auth).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(409)
        allow(response).to receive(:body).and_return(error.to_json)
        expect { TD::Users::Auth.sign_up(attrs) }.to raise_error TD::Users::AuthFailed
      end
    end

    context 'when server responds with unknown status code' do
      it 'raises a GenericError exception' do
        allow(TD::Users::Auth).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(500)
        allow(response).to receive(:body).and_return(nil)
        expect { TD::Users::Auth.sign_up(attrs) }.to raise_error TD::Users::GenericError
      end
    end
  end

  describe '.log_in' do
    context 'when server responds with 200' do
      it 'returns the auth with the token' do
        allow(TD::Users::Auth).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(200)
        allow(response).to receive(:body).and_return( { token: token }.to_json)
        auth = TD::Users::Auth.log_in(attrs)
        expect(auth.token).to eq token
        expect(auth.email).to eq attrs[:email]
      end
    end

    context 'when param is not a hash' do
      it 'raises an InvalidParam exception' do
        expect { TD::Users::Auth.log_in(Faker::Lorem.word) }.to raise_error TD::Users::InvalidParam
        expect do
          TD::Users::Auth.log_in(Faker::Number.number(3).to_i)
        end.to raise_error TD::Users::InvalidParam
        expect { TD::Users::Auth.log_in(Date.today) }.to raise_error TD::Users::InvalidParam
      end
    end

    context 'when server responds with 400' do
      it 'raises a ValidationError exception' do
        allow(TD::Users::Auth).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(400)
        allow(response).to receive(:body).and_return(error.to_json)
        expect { TD::Users::Auth.log_in(attrs) }.to raise_error TD::Users::ValidationError
      end
    end

    context 'when server responds with 401' do
      it 'raises a AuthFailed exception' do
        allow(TD::Users::Auth).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(401)
        allow(response).to receive(:body).and_return(error.to_json)
        expect { TD::Users::Auth.log_in(attrs) }.to raise_error TD::Users::AuthFailed
      end
    end

    context 'when server responds with 403' do
      it 'raises an AuthFailed exception' do
        allow(TD::Users::Auth).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(403)
        allow(response).to receive(:body).and_return(error.to_json)
        expect { TD::Users::Auth.log_in(attrs) }.to raise_error TD::Users::AuthFailed
      end
    end

    context 'when server responds with unknown status code' do
      it 'raises a GenericError exception' do
        allow(TD::Users::Auth).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(500)
        allow(response).to receive(:body).and_return(nil)
        expect { TD::Users::Auth.log_in(attrs) }.to raise_error TD::Users::GenericError
      end
    end
  end

  describe '.log_out' do
    context 'when server responds with 200' do
      it 'returns true' do
        allow(TD::Users::Auth).to receive(:get).and_return(response)
        allow(response).to receive(:code).and_return(200)
        allow(response).to receive(:body).and_return({})
        expect(TD::Users::Auth.log_out(user_id)).to eq true
      end
    end

    context 'when param is not a String' do
      it 'raises an InvalidParam exception' do
        expect do
          TD::Users::Auth.log_out(hey: Faker::Lorem.word)
        end.to raise_error TD::Users::InvalidParam
        expect do
          TD::Users::Auth.log_out(Faker::Number.number(3).to_i)
        end.to raise_error TD::Users::InvalidParam
        expect { TD::Users::Auth.log_out(Date.today) }.to raise_error TD::Users::InvalidParam
      end
    end

    context 'when server responds with 401' do
      it 'raises an AuthFailed exception' do
        allow(TD::Users::Auth).to receive(:get).and_return(response)
        allow(response).to receive(:code).and_return(401)
        allow(response).to receive(:body).and_return(error.to_json)
        expect { TD::Users::Auth.log_out(user_id) }.to raise_error TD::Users::AuthFailed
      end
    end

    context 'when server responds with unknown status code' do
      it 'raises a GenericError exception' do
        allow(TD::Users::Auth).to receive(:get).and_return(response)
        allow(response).to receive(:code).and_return(500)
        allow(response).to receive(:body).and_return(nil)
        expect { TD::Users::Auth.log_out(user_id) }.to raise_error TD::Users::GenericError
      end
    end
  end

  describe '.facebook' do
    context 'when server responds with 200' do
      it 'returns the auth with the token' do
        allow(TD::Users::Auth).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(200)
        allow(response).to receive(:body).and_return( { token: token }.to_json)
        auth = TD::Users::Auth.facebook(token)
        expect(auth.token).to eq token
      end
    end

    context 'when param is not a String' do
      it 'raises an InvalidParam exception' do
        expect do
          TD::Users::Auth.facebook(hey: Faker::Lorem.word)
        end.to raise_error TD::Users::InvalidParam
        expect do
          TD::Users::Auth.facebook(Faker::Number.number(3).to_i)
        end.to raise_error TD::Users::InvalidParam
        expect { TD::Users::Auth.facebook(Date.today) }.to raise_error TD::Users::InvalidParam
      end
    end

    context 'when server responds with 401' do
      it 'raises an AuthFailed exception' do
        allow(TD::Users::Auth).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(401)
        allow(response).to receive(:body).and_return(error.to_json)
        expect { TD::Users::Auth.facebook(token) }.to raise_error TD::Users::AuthFailed
      end
    end

    context 'when server responds with 403' do
      it 'raises an AuthFailed exception' do
        allow(TD::Users::Auth).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(403)
        allow(response).to receive(:body).and_return(error.to_json)
        expect { TD::Users::Auth.facebook(token) }.to raise_error TD::Users::AuthFailed
      end
    end

    context 'when server responds with unknown status code' do
      it 'raises a GenericError exception' do
        allow(TD::Users::Auth).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(500)
        allow(response).to receive(:body).and_return(nil)
        expect { TD::Users::Auth.facebook(token) }.to raise_error TD::Users::GenericError
      end
    end
  end

  describe '.verify' do
    context 'when server responds with 200' do
      it 'returns true' do
        allow(TD::Users::Auth).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(200)
        allow(response).to receive(:body).and_return({})
        expect(TD::Users::Auth.verify(attrs)).to eq true
      end
    end

    context 'when param is not a hash' do
      it 'raises an InvalidParam exception' do
        expect { TD::Users::Auth.verify(Faker::Lorem.word) }.to raise_error TD::Users::InvalidParam
        expect do
          TD::Users::Auth.verify(Faker::Number.number(3).to_i)
        end.to raise_error TD::Users::InvalidParam
        expect { TD::Users::Auth.verify(Date.today) }.to raise_error TD::Users::InvalidParam
      end
    end

    context 'when server responds with 400' do
      it 'raises a ValidationError exception' do
        allow(TD::Users::Auth).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(400)
        allow(response).to receive(:body).and_return(error.to_json)
        expect { TD::Users::Auth.verify(attrs) }.to raise_error TD::Users::ValidationError
      end
    end

    context 'when server responds with 401' do
      it 'raises an AuthFailed exception' do
        allow(TD::Users::Auth).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(401)
        allow(response).to receive(:body).and_return(error.to_json)
        expect { TD::Users::Auth.verify(attrs) }.to raise_error TD::Users::AuthFailed
      end
    end

    context 'when server responds with unknown status code' do
      it 'raises a GenericError exception' do
        allow(TD::Users::Auth).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(500)
        allow(response).to receive(:body).and_return(nil)
        expect { TD::Users::Auth.verify(attrs) }.to raise_error TD::Users::GenericError
      end
    end
  end

  describe '.verify_request' do
    context 'when server responds with 200' do
      it 'returns true' do
        allow(TD::Users::Auth).to receive(:get).and_return(response)
        allow(response).to receive(:code).and_return(200)
        allow(response).to receive(:body).and_return({})
        expect(TD::Users::Auth.verify_request(user_id)).to eq true
      end
    end

    context 'when param is not a String' do
      it 'raises an InvalidParam exception' do
        expect do
          TD::Users::Auth.verify_request(hey: Faker::Lorem.word)
        end.to raise_error TD::Users::InvalidParam
        expect do
          TD::Users::Auth.verify_request(Faker::Number.number(3).to_i)
        end.to raise_error TD::Users::InvalidParam
        expect { TD::Users::Auth.verify_request(Date.today) }.to raise_error TD::Users::InvalidParam
      end
    end

    context 'when server responds with 400' do
      it 'raises a ValidationError exception' do
        allow(TD::Users::Auth).to receive(:get).and_return(response)
        allow(response).to receive(:code).and_return(400)
        allow(response).to receive(:body).and_return(error.to_json)
        expect { TD::Users::Auth.verify_request(user_id) }.to raise_error TD::Users::ValidationError
      end
    end

    context 'when server responds with 401' do
      it 'raises an AuthFailed exception' do
        allow(TD::Users::Auth).to receive(:get).and_return(response)
        allow(response).to receive(:code).and_return(401)
        allow(response).to receive(:body).and_return(error.to_json)
        expect { TD::Users::Auth.verify_request(user_id) }.to raise_error TD::Users::AuthFailed
      end
    end

    context 'when server responds with unknown status code' do
      it 'raises a GenericError exception' do
        allow(TD::Users::Auth).to receive(:get).and_return(response)
        allow(response).to receive(:code).and_return(500)
        allow(response).to receive(:body).and_return(nil)
        expect { TD::Users::Auth.verify_request(user_id) }.to raise_error TD::Users::GenericError
      end
    end
  end

  describe '.reset_password_request' do
    context 'when server responds with 200' do
      it 'returns an auth with token email' do
        allow(TD::Users::Auth).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(200)
        allow(response).to receive(:body)
          .and_return({ user: { email: email }, emailToken: token }.to_json)
        auth = TD::Users::Auth.reset_password_request(email)
        expect(auth.email_token).to eq token
        expect(auth.email).to eq email
      end
    end

    context 'when param is not a String' do
      it 'raises an InvalidParam exception' do
        expect do
          TD::Users::Auth.verify_request(hey: Faker::Lorem.word)
        end.to raise_error TD::Users::InvalidParam
        expect do
          TD::Users::Auth.verify_request(Faker::Number.number(3).to_i)
        end.to raise_error TD::Users::InvalidParam
        expect { TD::Users::Auth.reset_password_request(Date.today) }
          .to raise_error TD::Users::InvalidParam
      end
    end

    context 'when server responds with 400' do
      it 'raises a ValidationError exception' do
        allow(TD::Users::Auth).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(400)
        allow(response).to receive(:body).and_return(error.to_json)
        expect { TD::Users::Auth.reset_password_request(email) }
          .to raise_error TD::Users::ValidationError
      end
    end

    context 'when server responds with 401' do
      it 'raises an AuthFailed exception' do
        allow(TD::Users::Auth).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(401)
        allow(response).to receive(:body).and_return(error.to_json)
        expect { TD::Users::Auth.reset_password_request(email) }
          .to raise_error TD::Users::AuthFailed
      end
    end

    context 'when server responds with unknown status code' do
      it 'raises a GenericError exception' do
        allow(TD::Users::Auth).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(500)
        allow(response).to receive(:body).and_return(nil)
        expect { TD::Users::Auth.reset_password_request(email) }
          .to raise_error TD::Users::GenericError
      end
    end
  end

  describe '.reset_password' do
    context 'when server responds with 200' do
      it 'returns true' do
        allow(TD::Users::Auth).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(200)
        allow(response).to receive(:body).and_return({})
        expect(TD::Users::Auth.reset_password(attrs)).to eq true
      end
    end

    context 'when param is not a hash' do
      it 'raises an InvalidParam exception' do
        expect do
          TD::Users::Auth.reset_password(Faker::Lorem.word)
        end.to raise_error TD::Users::InvalidParam
        expect do
          TD::Users::Auth.reset_password(Faker::Number.number(3).to_i)
        end.to raise_error TD::Users::InvalidParam
        expect { TD::Users::Auth.reset_password(Date.today) }.to raise_error TD::Users::InvalidParam
      end
    end

    context 'when server responds with 400' do
      it 'raises a ValidationError exception' do
        allow(TD::Users::Auth).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(400)
        allow(response).to receive(:body).and_return(error.to_json)
        expect { TD::Users::Auth.reset_password(attrs) }.to raise_error TD::Users::ValidationError
      end
    end

    context 'when server responds with 401' do
      it 'raises an AuthFailed exception' do
        allow(TD::Users::Auth).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(401)
        allow(response).to receive(:body).and_return(error.to_json)
        expect { TD::Users::Auth.reset_password(attrs) }.to raise_error TD::Users::AuthFailed
      end
    end


    context 'when server responds with unknown status code' do
      it 'raises a GenericError exception' do
        allow(TD::Users::Auth).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(500)
        allow(response).to receive(:body).and_return(nil)
        expect { TD::Users::Auth.reset_password(attrs) }.to raise_error TD::Users::GenericError
      end
    end
  end

  describe '.update_password' do
    context 'when server responds with 200' do
      it 'returns true' do
        allow(TD::Users::Auth).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(200)
        allow(response).to receive(:body).and_return({})
        expect(TD::Users::Auth.update_password(attrs)).to eq true
      end
    end

    context 'when param is not a hash' do
      it 'raises an InvalidParam exception' do
        expect do
          TD::Users::Auth.update_password(Faker::Lorem.word)
        end.to raise_error TD::Users::InvalidParam
        expect do
          TD::Users::Auth.update_password(Faker::Number.number(3).to_i)
        end.to raise_error TD::Users::InvalidParam
        expect { TD::Users::Auth.update_password(Date.today) }
          .to raise_error TD::Users::InvalidParam
      end
    end

    context 'when server responds with 400' do
      it 'raises a ValidationError exception' do
        allow(TD::Users::Auth).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(400)
        allow(response).to receive(:body).and_return(error.to_json)
        expect { TD::Users::Auth.update_password(attrs) }.to raise_error TD::Users::ValidationError
      end
    end

    context 'when server responds with 401' do
      it 'raises an AuthFailed exception' do
        allow(TD::Users::Auth).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(401)
        allow(response).to receive(:body).and_return(error.to_json)
        expect { TD::Users::Auth.update_password(attrs) }.to raise_error TD::Users::AuthFailed
      end
    end

    context 'when server responds with unknown status code' do
      it 'raises a GenericError exception' do
        allow(TD::Users::Auth).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(500)
        allow(response).to receive(:body).and_return(nil)
        expect { TD::Users::Auth.update_password(attrs) }.to raise_error TD::Users::GenericError
      end
    end
  end

  describe '.update_email' do
    context 'when server responds with 200' do
      it 'returns true' do
        allow(TD::Users::Auth).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(200)
        allow(response).to receive(:body).and_return({})
        expect(TD::Users::Auth.update_email(attrs)).to eq true
      end
    end

    context 'when param is not a hash' do
      it 'raises an InvalidParam exception' do
        expect do
          TD::Users::Auth.update_email(Faker::Lorem.word)
        end.to raise_error TD::Users::InvalidParam
        expect do
          TD::Users::Auth.update_email(Faker::Number.number(3).to_i)
        end.to raise_error TD::Users::InvalidParam
        expect { TD::Users::Auth.update_email(Date.today) }.to raise_error TD::Users::InvalidParam
      end
    end

    context 'when server responds with 400' do
      it 'raises a ValidationError exception' do
        allow(TD::Users::Auth).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(400)
        allow(response).to receive(:body).and_return(error.to_json)
        expect { TD::Users::Auth.update_email(attrs) }.to raise_error TD::Users::ValidationError
      end
    end

    context 'when server responds with 401' do
      it 'raises an AuthFailed exception' do
        allow(TD::Users::Auth).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(401)
        allow(response).to receive(:body).and_return(error.to_json)
        expect { TD::Users::Auth.update_email(attrs) }.to raise_error TD::Users::AuthFailed
      end
    end

    context 'when server responds with unknown status code' do
      it 'raises a GenericError exception' do
        allow(TD::Users::Auth).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(500)
        allow(response).to receive(:body).and_return(nil)
        expect { TD::Users::Auth.update_email(attrs) }.to raise_error TD::Users::GenericError
      end
    end
  end
end
