require 'casa-attribute/loader'
require 'casa-receiver/adj_in_translate/strategy'
require 'casa-receiver/adj_in_squash/strategy'
require 'casa-receiver/adj_in_filter/strategy'
require 'casa-receiver/adj_in_transform/strategy'

module CASA
  module Receiver
    module Payload
      class Strategy

        attr_reader :attributes
        attr_reader :adj_in_translate_strategy
        attr_reader :adj_in_squash_strategy
        attr_reader :adj_in_filter_strategy
        attr_reader :adj_in_transform_strategy

        def initialize options

          @options = options
          @attributes = load_attributes! @options['attributes']
          @adj_in_translate_strategy = CASA::Receiver::AdjInTranslate::Strategy.factory @attributes
          @adj_in_squash_strategy = CASA::Receiver::AdjInSquash::Strategy.factory @attributes
          @adj_in_filter_strategy = CASA::Receiver::AdjInFilter::Strategy.factory @attributes
          @adj_in_transform_strategy = CASA::Receiver::AdjInTransform::Strategy.factory @attributes

        end

        def load_attributes! attributes

          attributes.each { |attribute| CASA::Attribute::Loader.load! attribute }
          CASA::Attribute::Loader.loaded

        end

        def process payload

          payload_hash = adj_in_translate_strategy.execute payload
          adj_in_squash_strategy.execute! payload_hash
          return false unless adj_in_filter_strategy.allows? payload_hash
          adj_in_transform_strategy.execute! payload_hash
          payload_hash

        end

      end
    end
  end
end