module TD
  module Users
    class AuthFailed < Exception
      def self.message(response_body)
        "#{response_body['message']} #{response_body['errors']}"
      end
    end
  end
end
