module TD
  module Users
    class ValidationError < Exception
      def self.message(response_body)
        "#{response_body['message']} #{response_body['errors']}"
      end
    end
  end
end
