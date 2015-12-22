module TD
  module Users
    class Auth < Resource
      include TD::Core::Helpers::Object

      TD::Users.on_configure do
        base_uri "#{TD::Users.configuration.base_url}#{TD::Users.configuration.auth_url}"
      end

      ATTRS = [:user_id, :token, :email, :email_token]

      attr_accessor(*ATTRS)

      def initialize(attrs = {})
        attrs.each do |key, value|
          instance_variable_set("@#{key}", value)
        end
      end

      def self.sign_up(attrs)
        validate_param(attrs, Hash)
        attrs_to_send = camelize_attributes(attrs)
        response = post(TD::Users.configuration.sign_up, body: attrs_to_send)
        case response.code
        when 200
          json_response = JSON.parse(response.body)
          token = underscore_attributes(json_response)
          Auth.new(user_id: attrs_to_send[:userId], token: token[:token],
                   email: attrs_to_send[:email])
        when 400 then raise ValidationError, ValidationError.message(JSON.parse(response.body))
        when 401 then raise AuthFailed, AuthFailed.message(JSON.parse(response.body))
        when 403 then raise AuthFailed, AuthFailed.message(JSON.parse(response.body))
        when 404 then raise AuthFailed, AuthFailed.message(JSON.parse(response.body))
        when 409 then raise AuthFailed, AuthFailed.message(JSON.parse(response.body))
        else raise GenericError, GenericError.message(response.code, response.body)
        end
      end

      def self.log_in(attrs)
        validate_param(attrs, Hash)
        attrs_to_send = camelize_attributes(attrs)
        response = post(TD::Users.configuration.log_in, body: attrs_to_send)
        case response.code
        when 200
          json_response = JSON.parse(response.body)
          token = underscore_attributes(json_response)
          Auth.new(token: token[:token], email: attrs_to_send[:email])
        when 400 then raise ValidationError, ValidationError.message(JSON.parse(response.body))
        when 401 then raise AuthFailed, AuthFailed.message(JSON.parse(response.body))
        when 403 then raise AuthFailed, AuthFailed.message(JSON.parse(response.body))
        else raise GenericError, GenericError.message(response.code, response.body)
        end
      end

      def self.log_out(user_id)
        validate_param(user_id, String)
        response = get(TD::Users.configuration.log_out % user_id)
        case response.code
        when 200 then true
        when 401 then raise AuthFailed, AuthFailed.message(JSON.parse(response.body))
        else raise GenericError, GenericError.message(response.code, response.body)
        end
      end

      def self.facebook(facebook_token)
        validate_param(facebook_token, String)
        response = post(TD::Users.configuration.facebook, body: { facebookToken: facebook_token } )
        case response.code
        when 200
          json_response = JSON.parse(response.body)
          token = underscore_attributes(json_response)
          Auth.new(token: token[:token])
        when 400 then raise ValidationError, ValidationError.message(JSON.parse(response.body))
        when 401 then raise AuthFailed, AuthFailed.message(JSON.parse(response.body))
        when 403 then raise AuthFailed, AuthFailed.message(JSON.parse(response.body))
        else raise GenericError, GenericError.message(response.code, response.body)
        end
      end

      def self.verify(attrs)
        validate_param(attrs, Hash)
        attrs_to_send = camelize_attributes(attrs)
        response = post(TD::Users.configuration.verify, body: attrs_to_send)
        case response.code
        when 200 then true
        when 400 then raise ValidationError, ValidationError.message(JSON.parse(response.body))
        when 401 then raise AuthFailed, AuthFailed.message(JSON.parse(response.body))
        else raise GenericError, GenericError.message(response.code, response.body)
        end
      end

      def self.verify_request(user_id)
        validate_param(user_id, String)
        response = get(TD::Users.configuration.verify_request % user_id)
        case response.code
        when 200 then true
        when 400 then raise ValidationError, ValidationError.message(JSON.parse(response.body))
        when 401 then raise AuthFailed, AuthFailed.message(JSON.parse(response.body))
        else raise GenericError, GenericError.message(response.code, response.body)
        end
      end

      def self.reset_password_request(email)
        validate_param(email, String)
        response = post(TD::Users.configuration.reset_password_request, body: { email: email } )
        case response.code
        when 200
          resp = underscore_attributes(JSON.parse(response.body))
          Auth.new(email: resp[:user][:email.to_s], email_token: resp[:email_token])
        when 400 then raise ValidationError, ValidationError.message(JSON.parse(response.body))
        when 401 then raise AuthFailed, AuthFailed.message(JSON.parse(response.body))
        else raise GenericError, GenericError.message(response.code, response.body)
        end
      end

      def self.reset_password(attrs)
        validate_param(attrs, Hash)
        attrs_to_send = camelize_attributes(attrs)
        response = post(TD::Users.configuration.reset_password, body: attrs_to_send)
        case response.code
        when 200 then true
        when 400 then raise ValidationError, ValidationError.message(JSON.parse(response.body))
        when 401 then raise AuthFailed, AuthFailed.message(JSON.parse(response.body))
        else raise GenericError, GenericError.message(response.code, response.body)
        end
      end

      def self.update_password(attrs)
        validate_param(attrs, Hash)
        attrs_to_send = camelize_attributes(attrs)
        response = post(TD::Users.configuration.update_password % attrs_to_send[:userId],
                        body: attrs_to_send)
        case response.code
        when 200 then true
        when 400 then raise ValidationError, ValidationError.message(JSON.parse(response.body))
        when 401 then raise AuthFailed, AuthFailed.message(JSON.parse(response.body))
        when 403 then raise AuthFailed, AuthFailed.message(JSON.parse(response.body))
        else raise GenericError, GenericError.message(response.code, response.body)
        end
      end

      def self.update_email(attrs)
        validate_param(attrs, Hash)
        attrs_to_send = camelize_attributes(attrs)
        response = post(TD::Users.configuration.update_email % attrs_to_send[:userId],
                        body: attrs_to_send)
        case response.code
        when 200 then true
        when 400 then raise ValidationError, ValidationError.message(JSON.parse(response.body))
        when 401 then raise AuthFailed, AuthFailed.message(JSON.parse(response.body))
        when 403 then raise AuthFailed, AuthFailed.message(JSON.parse(response.body))
        else raise GenericError, GenericError.message(response.code, response.body)
        end
      end
    end
  end
end
