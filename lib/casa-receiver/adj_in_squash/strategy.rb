require 'casa-operation/translate'

module CASA
  module Receiver
    module AdjInSquash
      class Strategy

        def self.factory attributes
          CASA::Receiver::AdjInSquash::Strategy.new attributes
        end

        attr_reader :attributes

        def initialize attributes
          @attributes = attributes
        end

        def execute! payload_hash

          payload_hash['attributes'] = {
            'originator_id' => payload_hash['identity']['originator_id'],
            'timestamp' => 'TIMESTAMP',
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