module CASA
  module Receiver
    module Strategy
      class AdjOutTransform

        def self.factory attributes
          CASA::Receiver::Strategy::AdjOutTransform.new attributes
        end

        attr_reader :attributes

        def initialize attributes
          @attributes = attributes
        end

        def execute! payload_hash
          @attributes.each do |attribute_name, attribute|
            payload_hash['attributes'][attribute.section][attribute_name] = attribute.out_transform payload_hash
          end
          payload_hash
        end

      end
    end
  end
end