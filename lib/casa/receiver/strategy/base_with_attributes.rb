module CASA
  module Receiver
    module Strategy
      class BaseWithAttributes

        class << self

          def factory attributes
            self.new attributes
          end

          def attribute_method method
            (@@attribute_method ||= {})[name] = method
          end

        end

        attr_reader :attributes

        def initialize attributes
          @attributes = attributes
        end

        def attribute_method
          @@attribute_method[self.class.name]
        end

        def execute_method_over_attributes! method, payload_hash, type = nil
          payload_type_hash = type ? payload_hash[type] : payload_hash
          attributes.each do |attribute_name, attribute|
            payload_type_hash[attribute.section][attribute_name] = attribute.send method, payload_hash
          end
          payload_hash
        end

        def execute_attribute_method_over_attributes! payload_hash, type = nil
          execute_method_over_attributes! attribute_method, payload_hash, type
        end

        def reduce_attributes_with_method! method, payload_hash, type = nil
          payload_type_hash = type ? payload_hash[type] : payload_hash
          attributes.values.inject(true) { |result, attribute| result && attribute.send(method, payload_type_hash) }
        end

        def reduce_attributes_with_attribute_method! payload_hash, type = nil
          reduce_attributes_with_method! attribute_method, payload_hash, type
        end

      end
    end
  end
end