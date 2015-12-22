require 'spec_helper'
require 'faker'
require 'active_support/all'
require 'httparty'

describe TD::Users::User do
  let(:attrs) do
    { first_name: Faker::Lorem.word, last_name: Faker::Lorem.word,
      birth_date: Faker::Date.between(80.years.ago, 10.years.ago),
      email: Faker::Internet.email, gender: 'male', height: Faker::Number.between(140, 210),
      weight: Faker::Number.between(45, 120), addresses: [], contacts: [],
      roles: [Faker::Lorem.word, Faker::Lorem.word],
      created_at: Faker::Date.backward(100), updated_at: Faker::Date.backward(20) }
  end
  let(:response) { double("Response") }
  let(:id) { Faker::Lorem.sentence }
  let(:error) do
    { code: "ValidationError", message: "Field error description",
      errors: "Optional array with detail of errors" }
  end
  let(:contact) do
    { label: Faker::Lorem.word, type: 'telephone', value: Faker::Number.number(8).to_i,
      user_id: id }
  end
  let(:address) do
    { type: 'shipping', label: Faker::Lorem.word, address1: Faker::Address.street_address,
      address2: Faker::Address.street_address, city: Faker::Address.city,
      state: Faker::Address.state, country: Faker::Address.country, zip_code: Faker::Address.zip,
      user_id: id }
  end
  let(:user_obj) { TD::Users::User.new(attrs.merge(id: id)) }
  let(:contact_obj) { TD::Users::Contact.new(contact.merge(id: id)) }
  let(:address_obj) { TD::Users::Address.new(address.merge(id: id)) }
  describe '.new' do
    context 'when attributes are correct' do
      it 'creates the user' do
        user = TD::Users::User.new(attrs)
        expect(user.first_name).to eq attrs[:first_name]
        expect(user.last_name).to eq attrs[:last_name]
        expect(user.birth_date).to eq attrs[:birth_date]
        expect(user.gender).to eq attrs[:gender]
        expect(user.height).to eq attrs[:height]
        expect(user.weight).to eq attrs[:weight]
      end
    end

    context 'when it doesn\'t have attributes' do
      it 'creates the user' do
        user = TD::Users::User.new
        expect(user.first_name).to eq nil
        expect(user.last_name).to eq nil
        expect(user.birth_date).to eq nil
        expect(user.gender).to eq nil
        expect(user.height).to eq nil
        expect(user.weight).to eq nil
      end
    end
  end

  describe '.create' do
    context 'when attributes are correct' do
      it 'returns the user' do
        allow(TD::Users::User).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(200)
        allow(response).to receive(:body).and_return(attrs.merge(userId: id).to_json)
        user = TD::Users::User.create(attrs)
        expect(user.id).to eq id
        expect(user.first_name).to eq attrs[:first_name]
        expect(user.last_name).to eq attrs[:last_name]
        expect(user.gender).to eq attrs[:gender]
        expect(user.birth_date).to eq attrs[:birth_date]
        expect(user.height).to eq attrs[:height]
        expect(user.weight).to eq attrs[:weight]
      end
    end

    context 'when param is not a Hash' do
      it 'raises an InvalidParam exception' do
        expect { TD::Users::User.create(Faker::Lorem.word) }.to raise_error TD::Users::InvalidParam
        expect do
          TD::Users::User.create(Faker::Number.number(3).to_i)
        end.to raise_error TD::Users::InvalidParam
        expect { TD::Users::User.create(Date.today) }.to raise_error TD::Users::InvalidParam
      end
    end

    context 'when server responds with a 400' do
      it 'raises a ValidationError exception' do
        allow(TD::Users::User).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(400)
        allow(response).to receive(:body).and_return(error.to_json)
        expect { TD::Users::User.create(attrs) }.to raise_error TD::Users::ValidationError
      end
    end

    context 'when server responds with a 401' do
      it 'raises an AuthFailed exception' do
        allow(TD::Users::User).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(401)
        allow(response).to receive(:body).and_return(error.to_json)
        expect { TD::Users::User.create(attrs) }.to raise_error TD::Users::AuthFailed
      end
    end

    context 'when server responds with unknown status code' do
      it 'raises a GenericError exception' do
        allow(TD::Users::User).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(500)
        allow(response).to receive(:body).and_return(nil)
        expect { TD::Users::User.create(attrs) }.to raise_error TD::Users::GenericError
      end
    end
  end

  describe '.current' do
    context 'when token is valid' do
      it 'returns the user' do
        allow(TD::Users::User).to receive(:get).and_return(response)
        allow(response).to receive(:code).and_return(200)
        allow(response).to receive(:body).and_return(attrs.merge(_id: id).to_json)
        user = TD::Users::User.current(Faker::Lorem.sentence)
        expect(user.id).to eq id
        expect(user.first_name).to eq attrs[:first_name]
        expect(user.last_name).to eq attrs[:last_name]
        expect(user.gender).to eq attrs[:gender]
        expect(user.birth_date).to eq attrs[:birth_date]
        expect(user.email).to eq attrs[:email]
        expect(user.addresses).to eq attrs[:addresses]
        expect(user.contacts).to eq attrs[:contacts]
      end
    end

    context 'when param is not a String' do
      it 'raises an InvalidParam exception' do
        expect do
          TD::Users::User.current(hey: Faker::Lorem.word)
        end.to raise_error TD::Users::InvalidParam
        expect do
          TD::Users::User.current(Faker::Number.number(3).to_i)
        end.to raise_error TD::Users::InvalidParam
        expect { TD::Users::User.current(Date.today) }.to raise_error TD::Users::InvalidParam
      end
    end

    context 'when the token doesn\'t exist' do
      it 'raises an AuthFailed exception' do
        expect(TD::Users::User).to receive(:get).and_return(response)
        allow(response).to receive(:code).and_return(401)
        allow(response).to receive(:body).and_return(error.to_json)
        expect { TD::Users::User.current(Faker::Lorem.word) }.to raise_error TD::Users::AuthFailed
      end
    end

    context 'when server responds with a 401' do
      it 'raises an AuthFailed exception' do
        expect(TD::Users::User).to receive(:get).and_return(response)
        allow(response).to receive(:code).and_return(401)
        allow(response).to receive(:body).and_return(error.to_json)
        expect { TD::Users::User.current(Faker::Lorem.word) }.to raise_error TD::Users::AuthFailed
      end
    end

    context 'when server responds with unknown status code' do
      it 'raises a GenericError exception' do
        allow(TD::Users::User).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(500)
        allow(response).to receive(:body).and_return(nil)
        expect { TD::Users::User.create(attrs) }.to raise_error TD::Users::GenericError
      end
    end
  end

  describe '.update' do
    context 'when server responds with 200' do
      it 'returns the user' do
        allow(TD::Users::User).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(200)
        allow(response).to receive(:body).and_return(attrs.merge(_id: id).to_json)
        user = TD::Users::User.update(attrs.merge(id: id))
        expect(user.id).to eq id
      end
    end

    context 'when param is not a Hash' do
      it 'raises an InvalidParam exception' do
        expect { TD::Users::User.update(Faker::Lorem.word) }.to raise_error TD::Users::InvalidParam
        expect do
          TD::Users::User.update(Faker::Number.number(3).to_i)
        end.to raise_error TD::Users::InvalidParam
        expect { TD::Users::User.update(Date.today) }.to raise_error TD::Users::InvalidParam
      end
    end

    context 'when server responds with 400' do
      it 'raises a ValidationError exception' do
        allow(TD::Users::User).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(400)
        allow(response).to receive(:body).and_return(error.to_json)
        expect do
          TD::Users::User.update(attrs.merge(user_id: id))
        end.to raise_error TD::Users::ValidationError
      end
    end

    context 'when server responds with 401' do
      it 'raises an AuthFailed exception' do
        allow(TD::Users::User).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(401)
        allow(response).to receive(:body).and_return(error.to_json)
        expect do
          TD::Users::User.update(attrs.merge(user_id: id))
        end.to raise_error TD::Users::AuthFailed
      end
    end

    context 'when server responds with 403' do
      it 'raises an AuthFailed exception' do
        allow(TD::Users::User).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(403)
        allow(response).to receive(:body).and_return(error.to_json)
        expect do
          TD::Users::User.update(attrs.merge(user_id: id))
        end.to raise_error TD::Users::AuthFailed
      end
    end

    context 'when server responds with 404' do
      it 'raises a ValidationError exception' do
        allow(TD::Users::User).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(404)
        allow(response).to receive(:body).and_return(error.to_json)
        expect do
          TD::Users::User.update(attrs.merge(user_id: id))
        end.to raise_error TD::Users::ValidationError
      end
    end

    context 'when server responds with unknown status code' do
      it 'raises a GenericError exception' do
        allow(TD::Users::User).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(500)
        allow(response).to receive(:body).and_return(nil)
        expect do
          TD::Users::User.update(attrs.merge(user_id: id))
        end.to raise_error TD::Users::GenericError
      end
    end
  end

  describe '.find' do
    context 'when attributes are empty' do
      let(:user) { TD::Users::User.new(attrs) }
      it 'returns a list with all users' do
        allow(TD::Users::User).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(200)
        allow(response).to receive(:body)
          .and_return([attrs.merge(_id: id, create_at: attrs[:created_at],
                                   update_at: attrs[:updated_at])].to_json)
        users = TD::Users::User.find({})
        expect(users).to be_kind_of Array
        expect(users.length).to eq 1
        expect(users.first.first_name).to eq attrs[:first_name]
        expect(users.first.last_name).to eq attrs[:last_name]
        expect(users.first.gender).to eq attrs[:gender]
        expect(users.first.birth_date).to eq attrs[:birth_date]
        expect(users.first.addresses).to eq attrs[:addresses]
        expect(users.first.contacts).to eq attrs[:contacts]
        expect(users.first.roles).to eq attrs[:roles]
        expect(users.first.updated_at).to eq attrs[:updated_at]
        expect(users.first.created_at).to eq attrs[:created_at]
      end
    end

    context 'when param is not a Hash' do
      it 'raises an InvalidParam exception' do
        expect { TD::Users::User.find(Faker::Lorem.word) }.to raise_error TD::Users::InvalidParam
        expect do
          TD::Users::User.find(Faker::Number.number(3).to_i)
        end.to raise_error TD::Users::InvalidParam
        expect { TD::Users::User.find(Date.today) }.to raise_error TD::Users::InvalidParam
      end
    end

    context 'when server responds with a 400' do
      it 'raises a ValidationError exception' do
        allow(TD::Users::User).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(400)
        allow(response).to receive(:body).and_return(error.to_json)
        expect { TD::Users::User.find({}) }.to raise_error TD::Users::ValidationError
      end
    end

    context 'when server responds with a 401' do
      it 'raises an AuthFailed exception' do
        allow(TD::Users::User).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(401)
        allow(response).to receive(:body).and_return(error.to_json)
        expect { TD::Users::User.find({}) }.to raise_error TD::Users::AuthFailed
      end
    end

    context 'when server responds with unknown status code' do
      it 'raises a GenericError exception' do
        allow(TD::Users::User).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(500)
        allow(response).to receive(:body).and_return(nil)
        expect { TD::Users::User.find(attrs) }.to raise_error TD::Users::GenericError
      end
    end
  end

  describe '.add_contact' do
    context 'when attributes are correct' do
      it 'returns the added contact' do
        allow(TD::Users::User).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(200)
        allow(response).to receive(:body).and_return(contact.merge(contact_id: id).to_json)
        added_contact = TD::Users::User.add_contact(contact)
        expect(added_contact.id).to eq id
        expect(added_contact.label).to eq contact[:label]
        expect(added_contact.type).to eq contact[:type]
        expect(added_contact.value).to eq contact[:value]
        expect(added_contact.user_id).to eq contact[:user_id]
      end
    end

    context 'when param is not a Hash' do
      it 'raises an InvalidParam exception' do
        expect do
          TD::Users::User.add_contact(Faker::Lorem.word)
        end.to raise_error TD::Users::InvalidParam
        expect do
          TD::Users::User.add_contact(Faker::Number.number(3).to_i)
        end.to raise_error TD::Users::InvalidParam
        expect { TD::Users::User.add_contact(Date.today) }.to raise_error TD::Users::InvalidParam
      end
    end

    context 'when server responds with a 400' do
      it 'raises a ValidationError exception' do
        allow(TD::Users::User).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(400)
        allow(response).to receive(:body).and_return(error.to_json)
        expect { TD::Users::User.add_contact(attrs) }.to raise_error TD::Users::ValidationError
      end
    end

    context 'when server responds with a 401' do
      it 'raises an AuthFailed exception' do
        allow(TD::Users::User).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(401)
        allow(response).to receive(:body).and_return(error.to_json)
        expect { TD::Users::User.add_contact(attrs) }.to raise_error TD::Users::AuthFailed
      end
    end

    context 'when server responds with a 404' do
      it 'raises a ValidationError exception' do
        allow(TD::Users::User).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(404)
        allow(response).to receive(:body).and_return(error.to_json)
        expect { TD::Users::User.add_contact(attrs) }.to raise_error TD::Users::ValidationError
      end
    end

    context 'when server responds with unknown status code' do
      it 'raises a GenericError exception' do
        allow(TD::Users::User).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(500)
        allow(response).to receive(:body).and_return(nil)
        expect { TD::Users::User.add_contact(attrs) }.to raise_error TD::Users::GenericError
      end
    end
  end

  describe '.all_contacts' do
    context 'when user_id is correct' do
      it 'returns all user\'s contacts' do
        allow(TD::Users::User).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(200)
        allow(response).to receive(:body).and_return([contact.merge(contact_id: id)].to_json)
        contacts = TD::Users::User.all_contacts(id)
        expect(contacts).to be_kind_of Array
        expect(contacts.length).to eq 1
        expect(contacts.first.id).to eq id
        expect(contacts.first.type).to eq contact[:type]
        expect(contacts.first.user_id).to eq contact[:user_id]
      end
    end

    context 'when param is not a String' do
      it 'raises an InvalidParam exception' do
        expect do
          TD::Users::User.all_contacts(hey: Faker::Lorem.word)
        end.to raise_error TD::Users::InvalidParam
        expect do
          TD::Users::User.all_contacts(Faker::Number.number(3).to_i)
        end.to raise_error TD::Users::InvalidParam
        expect { TD::Users::User.all_contacts(Date.today) }.to raise_error TD::Users::InvalidParam
      end
    end

    context 'when user_id does\'t exist' do
      it 'raises a ValidationError exception' do
        allow(TD::Users::User).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(400)
        allow(response).to receive(:body).and_return(error.to_json)
        expect { TD::Users::User.all_contacts(id) }.to raise_error TD::Users::ValidationError
      end
    end

    context 'when server responds with a 400' do
      it 'raises a ValidationError exception' do
        allow(TD::Users::User).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(400)
        allow(response).to receive(:body).and_return(error.to_json)
        expect { TD::Users::User.all_contacts(id) }.to raise_error TD::Users::ValidationError
      end
    end

    context 'when server responds with a 401' do
      it 'raises an AuthFailed exception' do
        allow(TD::Users::User).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(401)
        allow(response).to receive(:body).and_return(error.to_json)
        expect { TD::Users::User.all_contacts(id) }.to raise_error TD::Users::AuthFailed
      end
    end

    context 'when server responds with a 404' do
      it 'raises a ValidationError exception' do
        allow(TD::Users::User).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(404)
        allow(response).to receive(:body).and_return(error.to_json)
        expect { TD::Users::User.all_contacts(id) }.to raise_error TD::Users::ValidationError
      end
    end

    context 'when server responds with unknown status code' do
      it 'raises a GenericError exception' do
        allow(TD::Users::User).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(500)
        allow(response).to receive(:body).and_return(nil)
        expect do
          TD::Users::User.all_contacts(Faker::Lorem.word)
        end.to raise_error TD::Users::GenericError
      end
    end
  end

  describe '.find_contact' do
    context 'when attributes all correct' do
      it 'returns the contact' do
        allow(TD::Users::User).to receive(:get).and_return(response)
        allow(response).to receive(:code).and_return(200)
        allow(response).to receive(:body).and_return(contact.merge(contact_id: id).to_json)
        found_contact = TD::Users::User.find_contact(contact)
        expect(found_contact.id).to eq id
        expect(found_contact.label).to eq contact[:label]
        expect(found_contact.type).to eq contact[:type]
        expect(found_contact.value).to eq contact[:value]
        expect(found_contact.user_id).to eq contact[:user_id]
      end
    end

    context 'when param is not a Hash' do
      it 'raises an InvalidParam exception' do
        expect do
          TD::Users::User.find_contact(Faker::Lorem.word)
        end.to raise_error TD::Users::InvalidParam
        expect do
          TD::Users::User.find_contact(Faker::Number.number(3).to_i)
        end.to raise_error TD::Users::InvalidParam
        expect { TD::Users::User.find_contact(Date.today) }.to raise_error TD::Users::InvalidParam
      end
    end

    context 'when server responds with a 400' do
      it 'raises a ValidationError exception' do
        allow(TD::Users::User).to receive(:get).and_return(response)
        allow(response).to receive(:code).and_return(400)
        allow(response).to receive(:body).and_return(error.to_json)
        expect { TD::Users::User.find_contact(contact) }.to raise_error TD::Users::ValidationError
      end
    end

    context 'when server responds with a 401' do
      it 'raises an AuthFailed exception' do
        allow(TD::Users::User).to receive(:get).and_return(response)
        allow(response).to receive(:code).and_return(401)
        allow(response).to receive(:body).and_return(error.to_json)
        expect { TD::Users::User.find_contact(contact) }.to raise_error TD::Users::AuthFailed
      end
    end

    context 'when server responds with a 404' do
      it 'raises a ValidationError exception' do
        allow(TD::Users::User).to receive(:get).and_return(response)
        allow(response).to receive(:code).and_return(404)
        allow(response).to receive(:body).and_return(error.to_json)
        expect { TD::Users::User.find_contact(contact) }.to raise_error TD::Users::ValidationError
      end
    end

    context 'when server responds with unknown status code' do
      it 'raises a GenericError exception' do
        allow(TD::Users::User).to receive(:get).and_return(response)
        allow(response).to receive(:code).and_return(500)
        allow(response).to receive(:body).and_return(nil)
        expect { TD::Users::User.find_contact(attrs) }.to raise_error TD::Users::GenericError
      end
    end
  end

  describe '.update_contact' do
    context 'when attributes are correct' do
      it 'returns the updated contact' do
        allow(TD::Users::User).to receive(:put).and_return(response)
        allow(response).to receive(:code).and_return(200)
        allow(response).to receive(:body).and_return(contact.merge(contact_id: id).to_json)
        updated_contact = TD::Users::User.update_contact(contact)
        expect(updated_contact.id).to eq id
        expect(updated_contact.value).to eq contact[:value]
        expect(updated_contact.user_id).to eq contact[:user_id]
      end
    end

    context 'when param is not a Hash' do
      it 'raises an InvalidParam exception' do
        expect do
          TD::Users::User.update_contact(Faker::Lorem.word)
        end.to raise_error TD::Users::InvalidParam
        expect do
          TD::Users::User.update_contact(Faker::Number.number(3).to_i)
        end.to raise_error TD::Users::InvalidParam
        expect { TD::Users::User.update_contact(Date.today) }.to raise_error TD::Users::InvalidParam
      end
    end

    context 'when server responds with a 400' do
      it 'raises a ValidationError exception' do
        allow(TD::Users::User).to receive(:put).and_return(response)
        allow(response).to receive(:code).and_return(400)
        allow(response).to receive(:body).and_return(contact.merge(contact_id: id).to_json)
        expect { TD::Users::User.update_contact(contact) }.to raise_error TD::Users::ValidationError
      end
    end

    context 'when server responds with a 401' do
      it 'raises an AuthFailed exception' do
        allow(TD::Users::User).to receive(:put).and_return(response)
        allow(response).to receive(:code).and_return(401)
        allow(response).to receive(:body).and_return(contact.merge(contact_id: id).to_json)
        expect { TD::Users::User.update_contact(contact) }.to raise_error TD::Users::AuthFailed
      end
    end

    context 'when server responds with a 404' do
      it 'raises a ValidationError exception' do
        allow(TD::Users::User).to receive(:put).and_return(response)
        allow(response).to receive(:code).and_return(404)
        allow(response).to receive(:body).and_return(contact.merge(contact_id: id).to_json)
        expect { TD::Users::User.update_contact(contact) }.to raise_error TD::Users::ValidationError
      end
    end

    context 'when server responds with unknown status code' do
      it 'raises a GenericError exception' do
        allow(TD::Users::User).to receive(:put).and_return(response)
        allow(response).to receive(:code).and_return(500)
        allow(response).to receive(:body).and_return(nil)
        expect { TD::Users::User.update_contact(attrs) }.to raise_error TD::Users::GenericError
      end
    end
  end

  describe '.delete_contact' do
    context 'when attributes are correct' do
      it 'returns true' do
        allow(TD::Users::User).to receive(:delete).and_return(response)
        allow(response).to receive(:code).and_return(200)
        expect(TD::Users::User.delete_contact(attrs)).to eq true
      end
    end

    context 'when param is not a Hash' do
      it 'raises an InvalidParam exception' do
        expect do
          TD::Users::User.delete_contact(Faker::Lorem.word)
        end.to raise_error TD::Users::InvalidParam
        expect do
          TD::Users::User.delete_contact(Faker::Number.number(3).to_i)
        end.to raise_error TD::Users::InvalidParam
        expect { TD::Users::User.delete_contact(Date.today) }.to raise_error TD::Users::InvalidParam
      end
    end

    context 'when server responds with a 400' do
      it 'raises a ValidationError exception' do
        allow(TD::Users::User).to receive(:delete).and_return(response)
        allow(response).to receive(:code).and_return(400)
        allow(response).to receive(:body).and_return(error.to_json)
        expect { TD::Users::User.delete_contact(attrs) }.to raise_error TD::Users::ValidationError
      end
    end

    context 'when server responds with a 401' do
      it 'raises an AuthFailed exception' do
        allow(TD::Users::User).to receive(:delete).and_return(response)
        allow(response).to receive(:code).and_return(401)
        allow(response).to receive(:body).and_return(error.to_json)
        expect { TD::Users::User.delete_contact(attrs) }.to raise_error TD::Users::AuthFailed
      end
    end

    context 'when server responds with a 404' do
      it 'raises a ValidationError exception' do
        allow(TD::Users::User).to receive(:delete).and_return(response)
        allow(response).to receive(:code).and_return(404)
        allow(response).to receive(:body).and_return(error.to_json)
        expect { TD::Users::User.delete_contact(attrs) }.to raise_error TD::Users::ValidationError
      end
    end

    context 'when server responds with unknown status code' do
      it 'raises a GenericError exception' do
        allow(TD::Users::User).to receive(:delete).and_return(response)
        allow(response).to receive(:code).and_return(500)
        allow(response).to receive(:body).and_return(nil)
        expect { TD::Users::User.delete_contact(attrs) }.to raise_error TD::Users::GenericError
      end
    end
  end

  describe '.add_address' do
    context 'when attributes are correct' do
      it 'returns the added address' do
        allow(TD::Users::User).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(200)
        allow(response).to receive(:body).and_return(address.merge(address_id: id).to_json)
        added_address = TD::Users::User.add_address(address)
        expect(added_address.id).to eq id
        expect(added_address.label).to eq address[:label]
        expect(added_address.type).to eq address[:type]
        expect(added_address.address1).to eq address[:address1]
        expect(added_address.address2).to eq address[:address2]
        expect(added_address.city).to eq address[:city]
        expect(added_address.state).to eq address[:state]
        expect(added_address.country).to eq address[:country]
        expect(added_address.zip_code).to eq address[:zip_code]
        expect(added_address.user_id).to eq address[:user_id]
      end
    end

    context 'when param is not a Hash' do
      it 'raises an InvalidParam exception' do
        expect do
          TD::Users::User.add_address(Faker::Lorem.word)
        end.to raise_error TD::Users::InvalidParam
        expect do
          TD::Users::User.add_address(Faker::Number.number(3).to_i)
        end.to raise_error TD::Users::InvalidParam
        expect { TD::Users::User.add_address(Date.today) }.to raise_error TD::Users::InvalidParam
      end
    end

    context 'when server responds with a 400' do
      it 'raises a ValidationError exception' do
        allow(TD::Users::User).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(400)
        allow(response).to receive(:body).and_return(error.to_json)
        expect { TD::Users::User.add_address(attrs) }.to raise_error TD::Users::ValidationError
      end
    end

    context 'when server responds with a 401' do
      it 'raises an AuthFailed exception' do
        allow(TD::Users::User).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(401)
        allow(response).to receive(:body).and_return(error.to_json)
        expect { TD::Users::User.add_address(attrs) }.to raise_error TD::Users::AuthFailed
      end
    end

    context 'when server responds with a 404' do
      it 'raises a ValidationError exception' do
        allow(TD::Users::User).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(404)
        allow(response).to receive(:body).and_return(error.to_json)
        expect { TD::Users::User.add_address(attrs) }.to raise_error TD::Users::ValidationError
      end
    end

    context 'when server responds with unknown status code' do
      it 'raises a GenericError exception' do
        allow(TD::Users::User).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(500)
        allow(response).to receive(:body).and_return(nil)
        expect { TD::Users::User.add_address(attrs) }.to raise_error TD::Users::GenericError
      end
    end
  end

  describe '.all_addresses' do
    context 'when user_id is correct' do
      it 'returns all user\'s addresses' do
        allow(TD::Users::User).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(200)
        allow(response).to receive(:body).and_return([address.merge(address_id: id)].to_json)
        addresses = TD::Users::User.all_addresses(id)
        expect(addresses).to be_kind_of Array
        expect(addresses.length).to eq 1
        expect(addresses.first.id).to eq id
        expect(addresses.first.type).to eq address[:type]
        expect(addresses.first.user_id).to eq address[:user_id]
      end
    end

    context 'when param is not a String' do
      it 'raises an InvalidParam exception' do
        expect do
          TD::Users::User.all_addresses(hey: Faker::Lorem.word)
        end.to raise_error TD::Users::InvalidParam
        expect do
          TD::Users::User.all_addresses(Faker::Number.number(3).to_i)
        end.to raise_error TD::Users::InvalidParam
        expect { TD::Users::User.all_addresses(Date.today) }.to raise_error TD::Users::InvalidParam
      end
    end

    context 'when user_id does\'t exist' do
      it 'raises a ValidationError exception' do
        allow(TD::Users::User).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(400)
        allow(response).to receive(:body).and_return(error.to_json)
        expect { TD::Users::User.all_addresses(id) }.to raise_error TD::Users::ValidationError
      end
    end

    context 'when server responds with a 400' do
      it 'raises a ValidationError exception' do
        allow(TD::Users::User).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(400)
        allow(response).to receive(:body).and_return(error.to_json)
        expect { TD::Users::User.all_addresses(id) }.to raise_error TD::Users::ValidationError
      end
    end

    context 'when server responds with a 401' do
      it 'raises an AuthFailed exception' do
        allow(TD::Users::User).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(401)
        allow(response).to receive(:body).and_return(error.to_json)
        expect { TD::Users::User.all_addresses(id) }.to raise_error TD::Users::AuthFailed
      end
    end

    context 'when server responds with a 404' do
      it 'raises a ValidationError exception' do
        allow(TD::Users::User).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(404)
        allow(response).to receive(:body).and_return(error.to_json)
        expect { TD::Users::User.all_addresses(id) }.to raise_error TD::Users::ValidationError
      end
    end

    context 'when server responds with unknown status code' do
      it 'raises a GenericError exception' do
        allow(TD::Users::User).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(500)
        allow(response).to receive(:body).and_return(nil)
        expect do
          TD::Users::User.all_addresses(Faker::Lorem.word)
        end.to raise_error TD::Users::GenericError
      end
    end
  end

  describe '.find_address' do
    context 'when attributes all correct' do
      it 'returns the address' do
        allow(TD::Users::User).to receive(:get).and_return(response)
        allow(response).to receive(:code).and_return(200)
        allow(response).to receive(:body).and_return(address.merge(address_id: id).to_json)
        found_address = TD::Users::User.find_address(address)
        expect(found_address.id).to eq id
        expect(found_address.label).to eq address[:label]
        expect(found_address.type).to eq address[:type]
        expect(found_address.address1).to eq address[:address1]
        expect(found_address.address2).to eq address[:address2]
        expect(found_address.city).to eq address[:city]
        expect(found_address.state).to eq address[:state]
        expect(found_address.country).to eq address[:country]
        expect(found_address.zip_code).to eq address[:zip_code]
        expect(found_address.user_id).to eq address[:user_id]
      end
    end

    context 'when param is not a Hash' do
      it 'raises an InvalidParam exception' do
        expect do
          TD::Users::User.find_address(Faker::Lorem.word)
        end.to raise_error TD::Users::InvalidParam
        expect do
          TD::Users::User.find_address(Faker::Number.number(3).to_i)
        end.to raise_error TD::Users::InvalidParam
        expect { TD::Users::User.find_address(Date.today) }.to raise_error TD::Users::InvalidParam
      end
    end

    context 'when server responds with a 400' do
      it 'raises a ValidationError exception' do
        allow(TD::Users::User).to receive(:get).and_return(response)
        allow(response).to receive(:code).and_return(400)
        allow(response).to receive(:body).and_return(error.to_json)
        expect { TD::Users::User.find_address(address) }.to raise_error TD::Users::ValidationError
      end
    end

    context 'when server responds with a 401' do
      it 'raises an AuthFailed exception' do
        allow(TD::Users::User).to receive(:get).and_return(response)
        allow(response).to receive(:code).and_return(401)
        allow(response).to receive(:body).and_return(error.to_json)
        expect { TD::Users::User.find_address(address) }.to raise_error TD::Users::AuthFailed
      end
    end

    context 'when server responds with a 404' do
      it 'raises a ValidationError exception' do
        allow(TD::Users::User).to receive(:get).and_return(response)
        allow(response).to receive(:code).and_return(404)
        allow(response).to receive(:body).and_return(error.to_json)
        expect { TD::Users::User.find_address(address) }.to raise_error TD::Users::ValidationError
      end
    end

    context 'when server responds with unknown status code' do
      it 'raises a GenericError exception' do
        allow(TD::Users::User).to receive(:get).and_return(response)
        allow(response).to receive(:code).and_return(500)
        allow(response).to receive(:body).and_return(nil)
        expect { TD::Users::User.find_address(attrs) }.to raise_error TD::Users::GenericError
      end
    end
  end

  describe '.update_address' do
    context 'when attributes are correct' do
      it 'returns the updated address' do
        allow(TD::Users::User).to receive(:put).and_return(response)
        allow(response).to receive(:code).and_return(200)
        allow(response).to receive(:body).and_return(address.merge(address_id: id).to_json)
        updated_address = TD::Users::User.update_address(address)
        expect(updated_address.id).to eq id
        expect(updated_address.label).to eq address[:label]
        expect(updated_address.address1).to eq address[:address1]
        expect(updated_address.address2).to eq address[:address2]
        expect(updated_address.city).to eq address[:city]
        expect(updated_address.state).to eq address[:state]
        expect(updated_address.country).to eq address[:country]
        expect(updated_address.zip_code).to eq address[:zip_code]
        expect(updated_address.user_id).to eq address[:user_id]
      end
    end

    context 'when param is not a Hash' do
      it 'raises an InvalidParam exception' do
        expect do
          TD::Users::User.update_address(Faker::Lorem.word)
        end.to raise_error TD::Users::InvalidParam
        expect do
          TD::Users::User.update_address(Faker::Number.number(3).to_i)
        end.to raise_error TD::Users::InvalidParam
        expect do
          TD::Users::User.update_address(Date.today)
        end.to raise_error TD::Users::InvalidParam
      end
    end

    context 'when server responds with a 400' do
      it 'raises a ValidationError exception' do
        allow(TD::Users::User).to receive(:put).and_return(response)
        allow(response).to receive(:code).and_return(400)
        allow(response).to receive(:body).and_return(address.merge(address_id: id).to_json)
        expect do
          TD::Users::User.update_address(address)
        end.to raise_error TD::Users::ValidationError
      end
    end

    context 'when server responds with a 401' do
      it 'raises an AuthFailed exception' do
        allow(TD::Users::User).to receive(:put).and_return(response)
        allow(response).to receive(:code).and_return(401)
        allow(response).to receive(:body).and_return(address.merge(address_id: id).to_json)
        expect do
          TD::Users::User.update_address(address)
        end.to raise_error TD::Users::AuthFailed
      end
    end

    context 'when server responds with a 404' do
      it 'raises a ValidationError exception' do
        allow(TD::Users::User).to receive(:put).and_return(response)
        allow(response).to receive(:code).and_return(404)
        allow(response).to receive(:body).and_return(address.merge(address_id: id).to_json)
        expect do
          TD::Users::User.update_address(address)
        end.to raise_error TD::Users::ValidationError
      end
    end

    context 'when server responds with unknown status code' do
      it 'raises a GenericError exception' do
        allow(TD::Users::User).to receive(:put).and_return(response)
        allow(response).to receive(:code).and_return(500)
        allow(response).to receive(:body).and_return(nil)
        expect { TD::Users::User.update_address(attrs) }.to raise_error TD::Users::GenericError
      end
    end
  end

  describe '.delete_address' do
    context 'when attributes are correct' do
      it 'returns true' do
        allow(TD::Users::User).to receive(:delete).and_return(response)
        allow(response).to receive(:code).and_return(200)
        expect(TD::Users::User.delete_address(attrs)).to eq true
      end
    end

    context 'when param is not a Hash' do
      it 'raises an InvalidParam exception' do
        expect do
          TD::Users::User.delete_address(Faker::Lorem.word)
        end.to raise_error TD::Users::InvalidParam
        expect do
          TD::Users::User.delete_address(Faker::Number.number(3).to_i)
        end.to raise_error TD::Users::InvalidParam
        expect { TD::Users::User.delete_address(Date.today) }.to raise_error TD::Users::InvalidParam
      end
    end

    context 'when server responds with a 400' do
      it 'raises a ValidationError exception' do
        allow(TD::Users::User).to receive(:delete).and_return(response)
        allow(response).to receive(:code).and_return(400)
        allow(response).to receive(:body).and_return(error.to_json)
        expect { TD::Users::User.delete_address(attrs) }.to raise_error TD::Users::ValidationError
      end
    end

    context 'when server responds with a 401' do
      it 'raises an AuthFailed exception' do
        allow(TD::Users::User).to receive(:delete).and_return(response)
        allow(response).to receive(:code).and_return(401)
        allow(response).to receive(:body).and_return(error.to_json)
        expect { TD::Users::User.delete_address(attrs) }.to raise_error TD::Users::AuthFailed
      end
    end

    context 'when server responds with a 404' do
      it 'raises a ValidationError exception' do
        allow(TD::Users::User).to receive(:delete).and_return(response)
        allow(response).to receive(:code).and_return(404)
        allow(response).to receive(:body).and_return(error.to_json)
        expect { TD::Users::User.delete_address(attrs) }.to raise_error TD::Users::ValidationError
      end
    end

    context 'when server responds with unknown status code' do
      it 'raises a GenericError exception' do
        allow(TD::Users::User).to receive(:delete).and_return(response)
        allow(response).to receive(:code).and_return(500)
        allow(response).to receive(:body).and_return(nil)
        expect { TD::Users::User.delete_address(attrs) }.to raise_error TD::Users::GenericError
      end
    end
  end

  describe '.add_relation' do
    context 'when server responds with 200' do
      it 'returns true' do
        allow(TD::Users::User).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(200)
        expect(TD::Users::User.add_relation(attrs)).to eq true
      end
    end

    context 'when param is not a Hash' do
      it 'raises an InvalidParam exception' do
        expect do
          TD::Users::User.add_relation(Faker::Lorem.word)
        end.to raise_error TD::Users::InvalidParam
        expect do
          TD::Users::User.add_relation(Faker::Number.number(3).to_i)
        end.to raise_error TD::Users::InvalidParam
        expect { TD::Users::User.add_relation(Date.today) }.to raise_error TD::Users::InvalidParam
      end
    end

    context 'when server responds with 401' do
      it 'raises an AuthFailed exception' do
        allow(TD::Users::User).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(401)
        allow(response).to receive(:body).and_return(error.to_json)
        expect { TD::Users::User.add_relation(attrs) }.to raise_error TD::Users::AuthFailed
      end
    end

    context 'when server responds with 404' do
      it 'raises a ValidationError exception' do
        allow(TD::Users::User).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(404)
        allow(response).to receive(:body).and_return(error.to_json)
        expect { TD::Users::User.add_relation(attrs) }.to raise_error TD::Users::ValidationError
      end
    end

    context 'when server respoonses with unknown status code' do
      it 'raises a GenericError exception' do
        allow(TD::Users::User).to receive(:post).and_return(response)
        allow(response).to receive(:code).and_return(500)
        allow(response).to receive(:body).and_return(nil)
        expect { TD::Users::User.add_relation(attrs) }.to raise_error TD::Users::GenericError
      end
    end
  end

  describe '#create' do
    context 'when attributes are correct' do
      it 'creates the user and returns true' do
        expect(TD::Users::User).to receive(:create).once.and_return(user_obj)
        user = TD::Users::User.new(attrs)
        response = user.create
        expect(user.id).to eq id
        expect(user.first_name).to eq attrs[:first_name]
        expect(user.last_name).to eq attrs[:last_name]
        expect(user.birth_date).to eq attrs[:birth_date]
        expect(response).to eq true
      end
    end

    context 'when .create raises a ValidationError' do
      it 'raises the same ValidationError' do
        expect(TD::Users::User).to receive(:create).once.and_raise(TD::Users::ValidationError)
        user = TD::Users::User.new(attrs)
        expect { user.create }.to raise_error TD::Users::ValidationError
      end
    end

    context 'when .create raises a GenericError' do
      it 'raises the same GenericError' do
        expect(TD::Users::User).to receive(:create).once.and_raise(TD::Users::GenericError)
        user = TD::Users::User.new(attrs)
        expect { user.create }.to raise_error TD::Users::GenericError
      end
    end
  end

  describe '#update' do
    context 'when attributes are correct' do
      it 'updates the user and returns true' do
        expect(TD::Users::User).to receive(:update).once.and_return(user_obj)
        user = TD::Users::User.new(attrs)
        response = user.update
        expect(user.id).to eq id
        expect(user.first_name).to eq attrs[:first_name]
        expect(user.last_name).to eq attrs[:last_name]
        expect(user.birth_date).to eq attrs[:birth_date]
        expect(response).to eq true
      end
    end

    context 'when .update raises a ValidationError' do
      it 'raises the same ValidationError' do
        expect(TD::Users::User).to receive(:update).once.and_raise(TD::Users::ValidationError)
        user = TD::Users::User.new(attrs)
        expect { user.update }.to raise_error TD::Users::ValidationError
      end
    end

    context 'when .update raises a GenericError' do
      it 'raises the same GenericError' do
        expect(TD::Users::User).to receive(:update).once.and_raise(TD::Users::GenericError)
        user = TD::Users::User.new(attrs)
        expect { user.update }.to raise_error TD::Users::GenericError
      end
    end
  end

  describe '#add_contact' do
    context 'when attributes are correct' do
      it 'adds the contact to the user' do
        expect(TD::Users::User).to receive(:add_contact).once.and_return(contact_obj)
        user = TD::Users::User.new(attrs)
        response = user.add_contact(contact)
        expect(user.contacts).not_to eq nil
        expect(user.contacts).not_to be_empty
        expect(user.contacts).to include contact_obj
        expect(response).to eq true
      end
    end

    context 'when user has nil contacts' do
      it 'adds the contact to the user' do
        expect(TD::Users::User).to receive(:add_contact).once.and_return(contact_obj)
        user = TD::Users::User.new(attrs.except(:contacts))
        response = user.add_contact(contact)
        expect(user.contacts).not_to eq nil
        expect(user.contacts).not_to be_empty
        expect(user.contacts).to include contact_obj
        expect(response).to eq true
      end
    end

    context 'when .add_contact raises a ValidationError' do
      it 'raises the same ValidationError' do
        expect(TD::Users::User).to receive(:add_contact).once.and_raise(TD::Users::ValidationError)
        user = TD::Users::User.new(attrs)
        expect { user.add_contact(contact) }.to raise_error TD::Users::ValidationError
      end
    end

    context 'when .add_contact raises a GenericError' do
      it 'raises the same GenericError' do
        expect(TD::Users::User).to receive(:add_contact).once.and_raise(TD::Users::GenericError)
        user = TD::Users::User.new(attrs)
        expect { user.add_contact(contact) }.to raise_error TD::Users::GenericError
      end
    end
  end

  describe '#all_contacts' do
    context 'when user instance already had the contacts' do
      it 'returns and keeps them in the variable' do
        expect(TD::Users::User).to receive(:all_contacts).once.and_return([contact_obj])
        user = TD::Users::User.new(attrs.merge(id: id, contacts: [contact_obj]))
        response = user.all_contacts
        expect(user.contacts).not_to eq nil
        expect(user.contacts).not_to be_empty
        expect(user.contacts).to eq [contact_obj]
        expect(response).to eq [contact_obj]
      end
    end

    context 'when user instance doesn\'t have contacts' do
      it 'refreshes the user contacts variable' do
        expect(TD::Users::User).to receive(:all_contacts).once.and_return([contact_obj])
        user = TD::Users::User.new(attrs.merge(id: id).except(:contacts))
        response = user.all_contacts
        expect(user.contacts).not_to eq nil
        expect(user.contacts).not_to be_empty
        expect(user.contacts).to eq [contact_obj]
        expect(response).to eq [contact_obj]
      end
    end

    context 'when .all_contacts raises a ValidationError' do
      it 'raises the same ValidationError' do
        expect(TD::Users::User).to receive(:all_contacts).once.and_raise(TD::Users::ValidationError)
        user = TD::Users::User.new(attrs)
        expect { user.all_contacts }.to raise_error TD::Users::ValidationError
      end
    end

    context 'when .all_contacts raises a GenericError' do
      it 'raises the same GenericError' do
        expect(TD::Users::User).to receive(:all_contacts).once.and_raise(TD::Users::GenericError)
        user = TD::Users::User.new(attrs)
        expect { user.all_contacts }.to raise_error TD::Users::GenericError
      end
    end
  end

  describe '#find_contact' do
    context 'when user already has that contact' do
      it 'updates the contact and keeps the same contacts size' do
        expect(TD::Users::User).to receive(:find_contact).once.and_return(contact_obj)
        user = TD::Users::User.new(attrs.merge(id: id, contacts: [contact_obj]))
        contacts_count = user.contacts.count
        response = user.find_contact(contact_obj.id)
        expect(user.contacts).not_to eq nil
        expect(user.contacts).not_to be_empty
        expect(user.contacts.count).to eq contacts_count
        expect(user.contacts).to include contact_obj
        expect(response).to eq contact_obj
      end
    end

    context 'when user doesn\'t have that contact' do
      it 'adds the contact to the contacts list' do
        expect(TD::Users::User).to receive(:find_contact).once.and_return(contact_obj)
        user = TD::Users::User.new(attrs.merge(id: id, contacts: []))
        response = user.find_contact(contact_obj.id)
        expect(user.contacts).not_to eq nil
        expect(user.contacts).not_to be_empty
        expect(user.contacts).to include contact_obj
        expect(response).to eq contact_obj
      end
    end

    context 'when user contacts attribute is nil' do
      it 'adds the contact to the contacts list' do
        expect(TD::Users::User).to receive(:find_contact).once.and_return(contact_obj)
        user = TD::Users::User.new(attrs.merge(id: id, contacts: nil))
        response = user.find_contact(contact_obj.id)
        expect(user.contacts).not_to eq nil
        expect(user.contacts).not_to be_empty
        expect(user.contacts).to include contact_obj
        expect(response).to eq contact_obj
      end
    end

    context 'when .find_contact raises a ValidationError' do
      it 'raises the same ValidationError' do
        expect(TD::Users::User).to receive(:find_contact).once.and_raise(TD::Users::ValidationError)
        user = TD::Users::User.new(attrs)
        expect { user.find_contact(id) }.to raise_error TD::Users::ValidationError
      end
    end

    context 'when .find_contact raises a GenericError' do
      it 'raises the same GenericError' do
        expect(TD::Users::User).to receive(:find_contact).once.and_raise(TD::Users::GenericError)
        user = TD::Users::User.new(attrs)
        expect { user.find_contact(id) }.to raise_error TD::Users::GenericError
      end
    end
  end

  describe '#update_contact' do
    context 'when user has that contact' do
      it 'updates the contact and keeps the same contacts size' do
        expect(TD::Users::User).to receive(:update_contact).once.and_return(contact_obj)
        user = TD::Users::User.new(attrs.merge(id: id, contacts: [contact_obj]))
        contacts_count = user.contacts.count
        response = user.update_contact(contact_obj.id, contact)
        expect(user.contacts).not_to eq nil
        expect(user.contacts).not_to be_empty
        expect(user.contacts.count).to eq contacts_count
        expect(user.contacts).to include contact_obj
        expect(response).to eq contact_obj
      end
    end

    context 'when user doesn\'t have that contact' do
      it 'raises a ValidationError exception' do
        expect(TD::Users::User).not_to receive(:update_contact)
        user = TD::Users::User.new(attrs.merge(id: id, contacts: []))
        expect do
          user.update_contact(contact_obj.id, contact)
        end.to raise_error TD::Users::ValidationError
      end
    end

    context 'when user contacts attribute is nil' do
      it 'raises a ValidationError exception' do
        expect(TD::Users::User).not_to receive(:update_contact)
        user = TD::Users::User.new(attrs.merge(id: id, contacts: nil))
        expect do
          user.update_contact(contact_obj.id, contact)
        end.to raise_error TD::Users::ValidationError
      end
    end

    context 'when .update_contact raises a ValidationError' do
      it 'raises the same ValidationError' do
        expect(TD::Users::User).to receive(:update_contact).once
          .and_raise(TD::Users::ValidationError)
        user = TD::Users::User.new(attrs.merge(contacts: [contact_obj]))
        expect do
          user.update_contact(contact_obj.id, contact)
        end.to raise_error TD::Users::ValidationError
      end
    end

    context 'when .update_contact raises a GenericError' do
      it 'raises the same GenericError' do
        expect(TD::Users::User).to receive(:update_contact).once.and_raise(TD::Users::GenericError)
        user = TD::Users::User.new(attrs.merge(contacts: [contact_obj]))
        expect do
          user.update_contact(contact_obj.id, contact)
        end.to raise_error TD::Users::GenericError
      end
    end
  end

  describe '#add_address' do
    context 'when attributes are correct' do
      it 'adds the address to the user' do
        expect(TD::Users::User).to receive(:add_address).once.and_return(address_obj)
        user = TD::Users::User.new(attrs)
        response = user.add_address(address)
        expect(user.addresses).not_to eq nil
        expect(user.addresses).not_to be_empty
        expect(user.addresses).to include address_obj
        expect(response).to eq true
      end
    end

    context 'when user has nil addresses' do
      it 'adds the address to the user' do
        expect(TD::Users::User).to receive(:add_address).once.and_return(address_obj)
        user = TD::Users::User.new(attrs.except(:addresses))
        response = user.add_address(address)
        expect(user.addresses).not_to eq nil
        expect(user.addresses).not_to be_empty
        expect(user.addresses).to include address_obj
        expect(response).to eq true
      end
    end

    context 'when .add_address raises a ValidationError' do
      it 'raises the same ValidationError' do
        expect(TD::Users::User).to receive(:add_address).once.and_raise(TD::Users::ValidationError)
        user = TD::Users::User.new(attrs)
        expect { user.add_address(address) }.to raise_error TD::Users::ValidationError
      end
    end

    context 'when .add_address raises a GenericError' do
      it 'raises the same GenericError' do
        expect(TD::Users::User).to receive(:add_address).once.and_raise(TD::Users::GenericError)
        user = TD::Users::User.new(attrs)
        expect { user.add_address(address) }.to raise_error TD::Users::GenericError
      end
    end
  end

  describe '#all_addresses' do
    context 'when user instance already had the addresses' do
      it 'returns and keeps them in the variable' do
        expect(TD::Users::User).to receive(:all_addresses).once.and_return([address_obj])
        user = TD::Users::User.new(attrs.merge(id: id, addresses: [address_obj]))
        response = user.all_addresses
        expect(user.addresses).not_to eq nil
        expect(user.addresses).not_to be_empty
        expect(user.addresses).to eq [address_obj]
        expect(response).to eq [address_obj]
      end
    end

    context 'when user instance doesn\'t have addresses' do
      it 'refreshes the user addresses variable' do
        expect(TD::Users::User).to receive(:all_addresses).once.and_return([address_obj])
        user = TD::Users::User.new(attrs.merge(id: id).except(:addresses))
        response = user.all_addresses
        expect(user.addresses).not_to eq nil
        expect(user.addresses).not_to be_empty
        expect(user.addresses).to eq [address_obj]
        expect(response).to eq [address_obj]
      end
    end

    context 'when .all_addresses raises a ValidationError' do
      it 'raises the same ValidationError' do
        expect(TD::Users::User).to receive(:all_addresses).once
          .and_raise(TD::Users::ValidationError)
        user = TD::Users::User.new(attrs)
        expect { user.all_addresses }.to raise_error TD::Users::ValidationError
      end
    end

    context 'when .all_addresses raises a GenericError' do
      it 'raises the same GenericError' do
        expect(TD::Users::User).to receive(:all_addresses).once.and_raise(TD::Users::GenericError)
        user = TD::Users::User.new(attrs)
        expect { user.all_addresses }.to raise_error TD::Users::GenericError
      end
    end
  end

  describe '#find_address' do
    context 'when user already has that address' do
      it 'updates the address and keeps the same addresses size' do
        expect(TD::Users::User).to receive(:find_address).once.and_return(address_obj)
        user = TD::Users::User.new(attrs.merge(id: id, addresses: [address_obj]))
        addresses_count = user.addresses.count
        response = user.find_address(address_obj.id)
        expect(user.addresses).not_to eq nil
        expect(user.addresses).not_to be_empty
        expect(user.addresses.count).to eq addresses_count
        expect(user.addresses).to include address_obj
        expect(response).to eq address_obj
      end
    end

    context 'when user doesn\'t have that address' do
      it 'adds the address to the addresses list' do
        expect(TD::Users::User).to receive(:find_address).once.and_return(address_obj)
        user = TD::Users::User.new(attrs.merge(id: id, addresses: []))
        response = user.find_address(address_obj.id)
        expect(user.addresses).not_to eq nil
        expect(user.addresses).not_to be_empty
        expect(user.addresses).to include address_obj
        expect(response).to eq address_obj
      end
    end

    context 'when user addresses attribute is nil' do
      it 'adds the address to the addresses list' do
        expect(TD::Users::User).to receive(:find_address).once.and_return(address_obj)
        user = TD::Users::User.new(attrs.merge(id: id, addresses: nil))
        response = user.find_address(address_obj.id)
        expect(user.addresses).not_to eq nil
        expect(user.addresses).not_to be_empty
        expect(user.addresses).to include address_obj
        expect(response).to eq address_obj
      end
    end

    context 'when .find_address raises a ValidationError' do
      it 'raises the same ValidationError' do
        expect(TD::Users::User).to receive(:find_address).once.and_raise(TD::Users::ValidationError)
        user = TD::Users::User.new(attrs)
        expect { user.find_address(id) }.to raise_error TD::Users::ValidationError
      end
    end

    context 'when .find_address raises a GenericError' do
      it 'raises the same GenericError' do
        expect(TD::Users::User).to receive(:find_address).once.and_raise(TD::Users::GenericError)
        user = TD::Users::User.new(attrs)
        expect { user.find_address(id) }.to raise_error TD::Users::GenericError
      end
    end
  end

  describe '#update_address' do
    context 'when user has that address' do
      it 'updates the address and keeps the same addresses size' do
        expect(TD::Users::User).to receive(:update_address).once.and_return(address_obj)
        user = TD::Users::User.new(attrs.merge(id: id, addresses: [address_obj]))
        addresses_count = user.addresses.count
        response = user.update_address(address_obj.id, address)
        expect(user.addresses).not_to eq nil
        expect(user.addresses).not_to be_empty
        expect(user.addresses.count).to eq addresses_count
        expect(user.addresses).to include address_obj
        expect(response).to eq address_obj
      end
    end

    context 'when user doesn\'t have that address' do
      it 'raises a ValidationError exception' do
        expect(TD::Users::User).not_to receive(:update_address)
        user = TD::Users::User.new(attrs.merge(id: id, addresses: []))
        expect do
          user.update_address(address_obj.id, address)
        end.to raise_error TD::Users::ValidationError
      end
    end

    context 'when user addresses attribute is nil' do
      it 'raises a ValidationError exception' do
        expect(TD::Users::User).not_to receive(:update_address)
        user = TD::Users::User.new(attrs.merge(id: id, addresses: nil))
        expect do
          user.update_address(address_obj.id, address)
        end.to raise_error TD::Users::ValidationError
      end
    end

    context 'when .update_address raises a ValidationError' do
      it 'raises the same ValidationError' do
        expect(TD::Users::User).to receive(:update_address).once
          .and_raise(TD::Users::ValidationError)
        user = TD::Users::User.new(attrs.merge(addresses: [address_obj]))
        expect do
          user.update_address(address_obj.id, address)
        end.to raise_error TD::Users::ValidationError
      end
    end

    context 'when .update_address raises a GenericError' do
      it 'raises the same GenericError' do
        expect(TD::Users::User).to receive(:update_address).once.and_raise(TD::Users::GenericError)
        user = TD::Users::User.new(attrs.merge(addresses: [address_obj]))
        expect do
          user.update_address(address_obj.id, address)
        end.to raise_error TD::Users::GenericError
      end
    end
  end
end
