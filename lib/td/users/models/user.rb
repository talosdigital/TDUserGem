module TD
  module Users
    class User < Resource
      include TD::Core::Helpers::Object

      TD::Users.on_configure do
        base_uri "#{TD::Users.configuration.base_url}#{TD::Users.configuration.user_url}"
      end

      ATTRS = [:id, :first_name, :last_name, :birth_date, :email, :gender, :height, :weight,
               :addresses, :contacts, :roles, :created_at, :updated_at, :auth, :metadata]
      attr_accessor(*ATTRS)

      def initialize(attrs = {})
        attrs.each do |key, value|
          instance_variable_set("@#{key}", value)
        end
      end

      # POST /user/create
      def self.create(attrs)
        validate_param(attrs, Hash)
        attrs_to_send = camelize_attributes(attrs)
        attrs_to_send[:birthDate] = format_date(attrs_to_send[:birthDate])
        if attrs_to_send[:metadata]
          attrs_to_send[:meta] = metadata_to_meta(attrs_to_send[:metadata])
          attrs_to_send.delete(:metadata)
        end
        response = post(TD::Users.configuration.create,
                        { headers: { 'Content-Type' => 'application/json' },
                          body: attrs_to_send.to_json } )
        case response.code
        when 200
          json_response = JSON.parse(response.body)
          created_user = underscore_attributes(json_response)
          user = underscore_attributes(attrs)
          User.new(id: created_user[:user_id], first_name: user[:first_name],
                   last_name: user[:last_name], birth_date: parse_date(user[:birth_date]),
                   gender: user[:gender], height: user[:height], weight: user[:weight],
                   metadata: user[:metadata])
        when 400 then raise ValidationError, ValidationError.message(JSON.parse(response.body))
        when 401 then raise AuthFailed, AuthFailed.message(JSON.parse(response.body))
        else raise GenericError, GenericError.message(response.code, response.body)
        end
      end

      def create
        attrs = self.to_hash_without_nils
        user = User.create(attrs)
        copy(user)
        true
      end

      # GET /user/current?token={token}
      def self.current(token)
        validate_param(token, String)
        response = get(TD::Users.configuration.current, query: { token: token } )
        case response.code
        when 200
          json_response = JSON.parse(response.body)
          user = underscore_attributes(json_response)
          # TODO: Parse contacts and addresses array to models.
          User.new(id: user[:_id], first_name: user[:first_name],
                   last_name: user[:last_name], gender: user[:gender],
                   birth_date: parse_date(user[:birth_date]),
                   email: user[:email], addresses: user[:addresses],
                   contacts: user[:contacts], roles: user[:roles],
                   metadata: meta_to_metadata(user[:meta]))
        when 401 then raise AuthFailed, AuthFailed.message(JSON.parse(response.body))
        else raise GenericError, GenericError.message(response.code, response.body)
        end
      end

      # POST /user/save
      def self.update(attrs)
        validate_param(attrs, Hash)
        attrs_to_send = camelize_attributes(attrs)
        attrs_to_send[:_id] = attrs_to_send[:id]
        if attrs_to_send[:metadata]
          attrs_to_send[:meta] = metadata_to_meta(attrs_to_send[:metadata])
          attrs_to_send.delete(:metadata)
        end
        response = post(TD::Users.configuration.update,
                        { headers: { 'Content-Type' => 'application/json' },
                          body: attrs_to_send.to_json })
        case response.code
        when 200
          json_response = JSON.parse(response.body)
          user = underscore_attributes(json_response)
          # TODO: Parse contacts and addresses array to models.
          User.new(id: user[:_id], first_name: user[:first_name],
                   last_name: user[:last_name], gender: user[:gender],
                   birth_date: parse_date(user[:birth_date]),
                   email: user[:email], addresses: user[:addresses],
                   contacts: user[:contacts], roles: user[:roles],
                   metadata: meta_to_metadata(user[:meta]))
        when 401 then raise AuthFailed, AuthFailed.message(JSON.parse(response.body))
        when 403 then raise AuthFailed, AuthFailed.message(JSON.parse(response.body))
        when 400 then raise ValidationError, ValidationError.message(JSON.parse(response.body))
        when 404 then raise ValidationError, ValidationError.message(JSON.parse(response.body))
        else raise GenericError, GenericError.message(response.code, response.body)
        end
      end

      def update
        attrs = self.to_hash_without_nils
        user = User.update(attrs)
        copy(user)
        true
      end

      # POST /user/find
      # TODO: Allow to receive dates in type Date.
      def self.find(attrs)
        validate_param(attrs, Hash)
        attrs_to_send = camelize_attributes(attrs)
        if attrs_to_send[:$or]
          attrs_to_send[:$or].map! do |filter_hash|
            camelize_attributes(filter_hash) if filter_hash.is_a?(Hash)
          end
        end
        if attrs_to_send[:Id]
          attrs_to_send[:_id] = attrs_to_send[:Id]
          attrs_to_send.delete(:Id)
        end
        if attrs_to_send[:id]
          attrs_to_send[:_id] = attrs_to_send[:id]
          attrs_to_send.delete(:id)
        end
        if attrs_to_send[:metadata]
          attrs_to_send[:meta] = metadata_to_meta(attrs_to_send[:metadata])
          attrs_to_send.delete(:metadata)
        end
        response = post(TD::Users.configuration.filter,
                        { headers: { 'Content-Type' => 'application/json' },
                          body: attrs_to_send.to_json } )
        case response.code
        when 200
          json_response = JSON.parse(response.body)
          response_array = []
          json_response.each do |current_user|
            sym_user = underscore_attributes(current_user)
            user = User.new(id: sym_user[:_id], first_name: sym_user[:first_name],
                            last_name: sym_user[:last_name], gender: sym_user[:gender],
                            birth_date: parse_date(sym_user[:birth_date]), email: sym_user[:email],
                            addresses: sym_user[:addresses], contacts: sym_user[:contacts],
                            roles: sym_user[:roles], created_at: parse_date(sym_user[:create_at]),
                            updated_at: parse_date(sym_user[:update_at]),
                            metadata: meta_to_metadata(sym_user[:meta]))
            response_array.push(user)
          end
          response_array
        when 400 then raise ValidationError, ValidationError.message(JSON.parse(response.body))
        when 401 then raise AuthFailed, AuthFailed.message(JSON.parse(response.body))
        else raise GenericError, GenericError.message(response.code, response.body)
        end
      end

      # POST /user/contact/create/userId/{userId}
      def self.add_contact(attrs)
        validate_param(attrs, Hash)
        attrs_to_send = camelize_attributes(attrs)
        response = post(TD::Users.configuration.add_contact % attrs_to_send[:userId],
                        body: attrs_to_send)
        case response.code
        when 200
          json_response = JSON.parse(response.body)
          created_contact = underscore_attributes(json_response)
          contact = underscore_attributes(attrs)
          Contact.new(id: created_contact[:contact_id], label: contact[:label],
                      type: contact[:type], value: contact[:value], user_id: contact[:user_id])
        when 400 then raise ValidationError, ValidationError.message(JSON.parse(response.body))
        when 401 then raise AuthFailed, AuthFailed.message(JSON.parse(response.body))
        when 404 then raise ValidationError, ValidationError.message(JSON.parse(response.body))
        else raise GenericError, GenericError.message(response.code, response.body)
        end
      end

      def add_contact(attrs)
        attrs_to_send = attrs.merge(user_id: self.id)
        contact = User.add_contact(attrs_to_send)
        self.contacts = [] unless self.contacts
        self.contacts.push(contact)
        true
      end

      # POST /user/contact/list/userId/{userId}
      def self.all_contacts(user_id)
        validate_param(user_id, String)
        response = post(TD::Users.configuration.all_contacts % user_id, body: { userId: user_id } )
        case response.code
        when 200
          json_response = JSON.parse(response.body)
          response_array = []
          json_response.each do |current_contact|
            sym_contact = underscore_attributes(current_contact)
            contact = Contact.new(id: sym_contact[:contact_id], type: sym_contact[:type],
                                  user_id: user_id)
            response_array.push(contact)
          end
          response_array
        when 400 then raise ValidationError, ValidationError.message(JSON.parse(response.body))
        when 401 then raise AuthFailed, AuthFailed.message(JSON.parse(response.body))
        when 404 then raise ValidationError, ValidationError.message(JSON.parse(response.body))
        else raise GenericError, GenericError.message(response.code, response.body)
        end
      end

      def all_contacts
        self.contacts = User.all_contacts(self.id)
      end

      # GET /user/contact/load/userId/{userId}/contactId/{contactId}
      def self.find_contact(attrs)
        validate_param(attrs, Hash)
        attrs_to_send = camelize_attributes(attrs)
        url = TD::Users.configuration.find_contact % [ attrs_to_send[:userId],
                                                       attrs_to_send[:contactId] ]
        response = get(url)
        case response.code
        when 200
          json_response = JSON.parse(response.body)
          contact = underscore_attributes(json_response)
          Contact.new(id: contact[:contact_id], label: contact[:label], type: contact[:type],
                      value: contact[:value], user_id: attrs_to_send[:userId])
        when 400 then raise ValidationError, ValidationError.message(JSON.parse(response.body))
        when 401 then raise AuthFailed, AuthFailed.message(JSON.parse(response.body))
        when 404 then raise ValidationError, ValidationError.message(JSON.parse(response.body))
        else raise GenericError, GenericError.message(response.code, response.body)
        end
      end

      def find_contact(contact_id)
        attrs = { user_id: self.id, contact_id: contact_id }
        found_contact = User.find_contact(attrs)
        self.contacts = [] unless self.contacts
        self.contacts.delete_if { |contact| contact.id == found_contact.id }
        self.contacts.push(found_contact)
        found_contact
      end

      # PUT /user/contact/update/userId/{userId}/contactId/{contactId}
      def self.update_contact(attrs)
        validate_param(attrs, Hash)
        attrs_to_send = camelize_attributes(attrs)
        url = TD::Users.configuration.update_contact % [ attrs_to_send[:userId],
                                                         attrs_to_send[:contactId] ]
        response = put(url, body: attrs_to_send)
        case response.code
        when 200
          json_response = underscore_attributes(JSON.parse(response.body))
          contact = underscore_attributes(attrs)
          Contact.new(id: json_response[:contact_id], value: contact[:value],
                      user_id: contact[:user_id])
        when 400 then raise ValidationError, ValidationError.message(JSON.parse(response.body))
        when 401 then raise AuthFailed, AuthFailed.message(JSON.parse(response.body))
        when 404 then raise ValidationError, ValidationError.message(JSON.parse(response.body))
        else raise GenericError, GenericError.message(response.code, response.body)
        end
      end

      def update_contact(contact_id, attrs)
        contact_to_update = nil
        self.contacts = [] unless self.contacts
        self.contacts.each { |contact| contact_to_update = contact if contact.id == contact_id }
        unless contact_to_update
          raise ValidationError, "This user doesn't have a contact with id='#{contact_id}', make "\
                                 "sure you've used the 'all_contacts' method to refresh user "\
                                 "contacts; or definitely the user doesn't have that contact."
        end
        attrs_to_send = attrs.merge(user_id: self.id, contact_id: contact_id)
        updated_contact = User.update_contact(attrs_to_send)
        contact_to_update.copy(updated_contact)
        contact_to_update
      end

      # DELETE /user/contact/delete/userId/{userId}/contactId/{contactId}
      def self.delete_contact(attrs)
        validate_param(attrs, Hash)
        attrs_to_send = camelize_attributes(attrs)
        url = TD::Users.configuration.delete_contact % [ attrs_to_send[:userId],
                                                         attrs_to_send[:contactId] ]
        response = delete(url)
        case response.code
        when 200 then true
        when 400 then raise ValidationError, ValidationError.message(JSON.parse(response.body))
        when 401 then raise AuthFailed, AuthFailed.message(JSON.parse(response.body))
        when 404 then raise ValidationError, ValidationError.message(JSON.parse(response.body))
        else raise GenericError, GenericError.message(response.code, response.body)
        end
      end

      # POST /user/address/create/userId/{userId}
      def self.add_address(attrs)
        validate_param(attrs, Hash)
        attrs_to_send = camelize_attributes(attrs)
        response = post(TD::Users.configuration.add_address % attrs_to_send[:userId],
                        body: attrs_to_send)
        case response.code
        when 200
          json_response = JSON.parse(response.body)
          created_address = underscore_attributes(json_response)
          address = underscore_attributes(attrs)
          Address.new(id: created_address[:address_id], label: address[:label],
                      type: address[:type], address1: address[:address1],
                      address2: address[:address2], city: address[:city], state: address[:state],
                      country: address[:country], zip_code: address[:zip_code],
                      user_id: address[:user_id])
        when 400 then raise ValidationError, ValidationError.message(JSON.parse(response.body))
        when 401 then raise AuthFailed, AuthFailed.message(JSON.parse(response.body))
        when 404 then raise ValidationError, ValidationError.message(JSON.parse(response.body))
        else raise GenericError, GenericError.message(response.code, response.body)
        end
      end

      def add_address(attrs)
        attrs_to_send = attrs.merge(user_id: self.id)
        address = User.add_address(attrs_to_send)
        self.addresses = [] unless self.addresses
        self.addresses.push(address)
        true
      end

      # POST /user/address/list/userId/{userId}
      def self.all_addresses(user_id)
        validate_param(user_id, String)
        response = post(TD::Users.configuration.all_addresses % user_id)
        case response.code
        when 200
          json_response = JSON.parse(response.body)
          response_array = []
          json_response.each do |current_address|
            sym_address = underscore_attributes(current_address)
            address = Address.new(id: sym_address[:address_id], type: sym_address[:type],
                                  user_id: user_id)
            response_array.push(address)
          end
          response_array
        when 400 then raise ValidationError, ValidationError.message(JSON.parse(response.body))
        when 401 then raise AuthFailed, AuthFailed.message(JSON.parse(response.body))
        when 404 then raise ValidationError, ValidationError.message(JSON.parse(response.body))
        else raise GenericError, GenericError.message(response.code, response.body)
        end
      end

      def all_addresses
        self.addresses = User.all_addresses(self.id)
      end

      # GET /user/address/load/userId/{userId}/addressId/{addressId}
      def self.find_address(attrs)
        validate_param(attrs, Hash)
        attrs_to_send = camelize_attributes(attrs)
        url = TD::Users.configuration.find_address % [ attrs_to_send[:userId],
                                                       attrs_to_send[:addressId] ]
        response = get(url)
        case response.code
        when 200
          json_response = JSON.parse(response.body)
          address = underscore_attributes(json_response)
          Address.new(id: address[:address_id], label: address[:label], type: address[:type],
                      address1: address[:address1], address2: address[:address2],
                      city: address[:city], state: address[:state], country: address[:country],
                      zip_code: address[:zip_code], user_id: attrs_to_send[:userId])
        when 400 then raise ValidationError, ValidationError.message(JSON.parse(response.body))
        when 401 then raise AuthFailed, AuthFailed.message(JSON.parse(response.body))
        when 404 then raise ValidationError, ValidationError.message(JSON.parse(response.body))
        else raise GenericError, GenericError.message(response.code, response.body)
        end
      end

      def find_address(address_id)
        attrs = { user_id: self.id, address_id: address_id }
        found_address = User.find_address(attrs)
        self.addresses = [] unless self.addresses
        self.addresses.delete_if { |address| address.id == found_address.id }
        self.addresses.push(found_address)
        found_address
      end

      # PUT /user/address/update/userId/{userId}/addressId/{addressId}
      def self.update_address(attrs)
        validate_param(attrs, Hash)
        attrs_to_send = camelize_attributes(attrs)
        url = TD::Users.configuration.update_address % [ attrs_to_send[:userId],
                                                         attrs_to_send[:addressId] ]
        response = put(url, body: attrs_to_send)
        case response.code
        when 200
          json_response = underscore_attributes(JSON.parse(response.body))
          address = underscore_attributes(attrs)
          Address.new(id: json_response[:address_id], label: address[:label],
                      address1: address[:address1], address2: address[:address2],
                      city: address[:city], state: address[:state], country: address[:country],
                      zip_code: address[:zip_code], user_id: address[:user_id])
        when 400 then raise ValidationError, ValidationError.message(JSON.parse(response.body))
        when 401 then raise AuthFailed, AuthFailed.message(JSON.parse(response.body))
        when 404 then raise ValidationError, ValidationError.message(JSON.parse(response.body))
        else raise GenericError, GenericError.message(response.code, response.body)
        end
      end

      def update_address(address_id, attrs)
        address_to_update = nil
        self.addresses = [] unless self.addresses
        self.addresses.each { |address| address_to_update = address if address.id == address_id }
        unless address_to_update
          raise ValidationError, "This user doesn't have an address with id='#{address_id}', make "\
                                 "sure you've used the 'all_addresses' method to refresh user "\
                                 "addresses; or definitely the user doesn't have that address."
        end
        attrs_to_send = attrs.merge(user_id: self.id, address_id: address_id)
        updated_address = User.update_address(attrs_to_send)
        address_to_update.copy(updated_address)
        address_to_update
      end

      # DELETE /user/address/delete/userId/{userId}/addressId/{addressId}
      def self.delete_address(attrs)
        validate_param(attrs, Hash)
        attrs_to_send = camelize_attributes(attrs)
        url = TD::Users.configuration.delete_address % [ attrs_to_send[:userId],
                                                         attrs_to_send[:addressId] ]
        response = delete(url)
        case response.code
        when 200 then true
        when 400 then raise ValidationError, ValidationError.message(JSON.parse(response.body))
        when 401 then raise AuthFailed, AuthFailed.message(JSON.parse(response.body))
        when 404 then raise ValidationError, ValidationError.message(JSON.parse(response.body))
        else raise GenericError, GenericError.message(response.code, response.body)
        end
      end

      # POST /user/relation/create
      def self.add_relation(attrs)
        validate_param(attrs, Hash)
        response = post(TD::Users.configuration.add_relation, body: camelize_attributes(attrs))
        case response.code
        when 200 then true
        when 401 then raise AuthFailed, AuthFailed.message(JSON.parse(response.body))
        when 404 then raise ValidationError, ValidationError.message(JSON.parse(response.body))
        else raise GenericError, GenericError.message(response.code, response.body)
        end
      end

      # GET /user/relation/list/userId/{userId}
      def self.all_relations(user_id)
      end

      def self.metadata_to_meta(metadata)
        ret = { data: metadata }
      end

      def self.meta_to_metadata(meta)
        meta['data'] if meta
      end

      private_class_method :metadata_to_meta, :meta_to_metadata
    end
  end
end
