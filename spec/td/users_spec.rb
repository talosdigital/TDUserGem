require 'spec_helper'

describe TD::Users do
  it 'has a version number' do
    expect(TD::Users::VERSION).not_to be nil
  end

  describe '.configure' do
    it 'sets base_url from within a block' do
      base_url = 'http://an.url.com'
      user_url = '/api/v1/user'
      TD::Users.configure do |config|
        config.base_url = base_url
        config.user_url = user_url
      end
      expect(TD::Users.configuration.base_url).to eq base_url
      expect(TD::Users.configuration.user_url).to eq user_url
    end

    it 'sets application_secret from within a block' do
      application_secret = 'v3ry_53cr37'
      TD::Users.configure do |config|
        config.application_secret = application_secret
      end
      expect(TD::Users.configuration.application_secret).to eq application_secret
    end

    it 'calls all registered on_configure listeners' do
      was_called = false
      TD::Users.on_configure do
        was_called = true
      end
      TD::Users.configure do |config|
        # Many configs.
      end
      expect(was_called).to be true
    end
  end
end
