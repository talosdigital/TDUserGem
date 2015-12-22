require 'httparty'

module TD
  module Users
    class Resource
      include HTTParty
      TD::Users.on_configure do
        headers 'authorization' => "#{TD::Users.configuration.application_secret}"
      end

      def self.validate_param(param, type)
        message = "#{param} is not a #{type}"
        raise InvalidParam, message unless param.is_a?(type)
      end
    end
  end
end
