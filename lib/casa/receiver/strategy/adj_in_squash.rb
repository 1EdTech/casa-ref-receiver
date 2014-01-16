module CASA
  module Receiver
    module Strategy
      class AdjInSquash

        def self.factory attributes
          CASA::Receiver::Strategy::AdjInSquash.new attributes
        end

        attr_reader :attributes

        def initialize attributes
          @attributes = attributes
        end

        def execute! payload_hash

          payload_hash['attributes'] = {
            'uri' => payload_hash['original']['uri'],
            'timestamp' => payload_hash['original']['timestamp'],
            'share' => payload_hash['original']['share'],
            'propagate' => payload_hash['original']['propagate'],
            'use' => {},
            'require' => {}
          }

          @attributes.each do |attribute_name, attribute|
            payload_hash['attributes'][attribute.section][attribute_name] = attribute.squash payload_hash
          end

          payload_hash

        end

      end
    end
  end
end