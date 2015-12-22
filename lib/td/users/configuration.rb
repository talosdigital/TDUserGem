require 'singleton'

module TD
  module Users
    # For a block { |config| ... }
    # @yield [config] passes the Configuration object.
    # @yieldparam config the Configuration object to be configured.
    # @see Configuration
    # @example Configure TD Users
    #   TD::Users.configure do |config|
    #     config.base_url = "http://td.user.com"
    #     config.user_url = "/api/v1/user"
    #     config.application_secret = "aB105-dF0a5-c40154abd-60adFE"
    #   end
    def self.configure
      yield Configuration.instance if block_given?
      Configuration.instance.listeners.each { |listener| listener.call }
    end

    # @return the current Configuration.
    def self.configuration
      Configuration.instance
    end

    def self.on_configure(&block)
      Configuration.instance.add_listener block
    end

    # Contains all configuration options and accessors.
    class Configuration
      include Singleton

      # The configuration options array. It's used to generate all the writers.
      CONFIG_OPTIONS = [:base_url, :user_url, :auth_url, :application_secret]
      # The user configuration options array. It's used to generate all the writers.
      USER_URLS = [:create, :current, :update, :filter, :add_contact, :all_contacts, :find_contact,
                   :update_contact, :delete_contact, :add_address, :all_addresses, :find_address,
                   :update_address, :delete_address, :add_relation, :all_relations]
      AUTH_URLS = [:sign_up, :log_in, :log_out, :facebook, :verify, :verify_request,
                   :reset_password_request, :reset_password, :update_password, :update_email]

      # @!attribute base_url
      # @return [String] sets the requests base url.

      # @!attribute user_url
      # @return [String] sets the requests user extension url.

      # @!attribute application_secret
      # @return [String] sets the application secret.

      attr_writer(*CONFIG_OPTIONS)

      # User options will be nil as default value.
      attr_accessor(*USER_URLS)

      # User options will be nil as default value.
      attr_accessor(*AUTH_URLS)

      def initialize
        @listeners = []
      end

      def add_listener(listener_lambda)
        @listeners << listener_lambda
      end

      def listeners
        @listeners
      end

      # Defaults to nil
      # @return [String] the target base_url where requests are made to.
      def base_url
        @base_url
      end

      # Defaults to nil
      # @return [String] the target user_url extension where requests are made to.
      def user_url
        @user_url
      end

      # Defaults to nil
      # @return [String] the target auth_url extension where requests are made to.
      def auth_url
        @auth_url
      end

      # Defaults to nil
      # @return [String] the application secret which allows other applications to make requests.
      def application_secret
        @application_secret
      end
    end
  end
end
