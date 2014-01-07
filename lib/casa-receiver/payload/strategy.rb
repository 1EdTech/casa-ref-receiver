require 'casa-attribute/loader'

module CASA
  module Receiver
    module Payload
      class Strategy

        attr_reader :attributes
        attr_reader :adj_in_translate_strategy

        def initialize options

          @options = options
          @attributes = load_attributes! @options['attributes']
          @adj_in_translate_strategy = CASA::Receiver::AdjInTranslate::Strategy.factory @attributes

        end

        def load_attributes! attributes

          attributes.each { |attribute| CASA::Attribute::Loader.load! attribute }
          CASA::Attribute::Loader.loaded

        end

        def process payload

          payload_hash = adj_in_translate_strategy.execute payload
          squash_payload_attributes payload_hash
          return false unless filter_payload_attributes payload_hash
          transform_payload_attributes payload_hash
          payload_hash

        end

        private

        def squash_payload_attributes payload_hash
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
        end

        def filter_payload_attributes payload_hash
          passes = true
          @attributes.each do |attribute_name, attribute|
            passes = passes and attribute.filter payload_hash
          end
          passes
        end

        def transform_payload_attributes payload_hash
          @attributes.each do |attribute_name, attribute|
            payload_hash['attributes'][attribute.section][attribute_name] = attribute.transform payload_hash
          end
        end

      end
    end
  end
end