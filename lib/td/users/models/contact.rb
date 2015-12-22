module TD
  module Users
    class Contact
      include TD::Core::Helpers::Object

      ATTRS = [:id, :label, :type, :value, :user_id]
      attr_accessor(*ATTRS)

      def initialize(attrs = {})
        attrs.each do |key, value|
          instance_variable_set("@#{key}", value)
        end
      end
    end
  end
end
