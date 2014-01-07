require 'casa-attribute/loader'

module CASA
  module Receiver
    module Strategy
      class Payload

        attr_reader :attributes

        def initialize options

          @options = options
          initialize_attributes! @options['attributes']

        end

        def initialize_attributes! attributes

          attributes.each { |attribute| CASA::Attribute::Loader.load! attribute }
          @attributes = CASA::Attribute::Loader.loaded

        end

        def process payload

          payload_hash = translate_payload payload
          squash_payload_attributes payload_hash
          return false unless filter_payload_attributes payload_hash
          transform_payload_attributes payload_hash
          payload_hash

        end

        private

        def translate_payload payload

          adj_in_translate_strategy = CASA::Receiver::AdjInTranslate::Strategy.new
          @attributes.each do |attribute_name, attribute|
            adj_in_translate_strategy.map attribute.uuid => attribute_name
          end
          adj_in_translate_strategy.execute payload

        end

        def squash_payload_attributes_base payload_hash

          payload_hash['attributes'] = {
            'originator_id' => payload_hash['identity']['originator_id'],
            'timestamp' => 'TIMESTAMP',
            'share' => payload_hash['original']['share'],
            'propagate' => payload_hash['original']['propagate'],
            'use' => {},
            'require' => {}
          }

        end

        def squash_payload_attributes payload_hash

          squash_payload_attributes_base payload_hash

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