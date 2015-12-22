module TD
  module Users
    class Address
      include TD::Core::Helpers::Object

      ATTRS = [:id, :label, :type, :address1, :address2, :city, :state, :country, :zip_code,
               :user_id]
      attr_accessor(*ATTRS)

      def initialize(attrs = {})
        attrs.each do |key, value|
          instance_variable_set("@#{key}", value)
        end
      end
    end
  end
end
