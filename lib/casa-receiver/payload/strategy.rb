require 'casa-attribute/loader'
require 'casa-receiver/adj_in_translate/strategy'
require 'casa-receiver/adj_in_squash/strategy'

module CASA
  module Receiver
    module Payload
      class Strategy

        attr_reader :attributes
        attr_reader :adj_in_translate_strategy
        attr_reader :adj_in_squash_strategy

        def initialize options

          @options = options
          @attributes = load_attributes! @options['attributes']
          @adj_in_translate_strategy = CASA::Receiver::AdjInTranslate::Strategy.factory @attributes
          @adj_in_squash_strategy = CASA::Receiver::AdjInSquash::Strategy.factory @attributes

        end

        def load_attributes! attributes

          attributes.each { |attribute| CASA::Attribute::Loader.load! attribute }
          CASA::Attribute::Loader.loaded

        end

        def process payload

          payload_hash = adj_in_translate_strategy.execute payload
          @adj_in_squash_strategy.execute! payload_hash
          return false unless filter_payload_attributes payload_hash
          transform_payload_attributes payload_hash
          payload_hash

        end

        private

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