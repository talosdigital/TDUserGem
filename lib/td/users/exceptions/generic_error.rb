module TD
  module Users
    class GenericError < Exception
      def self.message(code, body)
        "Server responsed with CODE: #{code} and BODY: #{body}"
      end
    end
  end
end
