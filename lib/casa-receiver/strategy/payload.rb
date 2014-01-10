require 'casa-attribute/loader'
require 'casa-receiver/strategy/adj_in_translate'
require 'casa-receiver/strategy/adj_in_squash'
require 'casa-receiver/strategy/adj_in_filter'
require 'casa-receiver/strategy/adj_in_transform'
require 'casa-receiver/strategy/adj_in_store'

module CASA
  module Receiver
    module Strategy
      class Payload

        attr_reader :options
        attr_reader :attributes
        attr_reader :adj_in_translate_strategy
        attr_reader :adj_in_squash_strategy
        attr_reader :adj_in_filter_strategy
        attr_reader :adj_in_transform_strategy
        attr_reader :adj_in_store

        def initialize options

          @options = options
          @attributes = build_attribute_handlers @options['attributes']
          @adj_in_translate_strategy = CASA::Receiver::Strategy::AdjInTranslate.factory @attributes
          @adj_in_squash_strategy = CASA::Receiver::Strategy::AdjInSquash.factory @attributes
          @adj_in_filter_strategy = CASA::Receiver::Strategy::AdjInFilter.factory @attributes
          @adj_in_transform_strategy = CASA::Receiver::Strategy::AdjInTransform.factory @attributes
          @adj_in_store = CASA::Receiver::Strategy::AdjInStore.factory @options['persistence']

        end

        def build_attribute_handlers attributes

          attributes.each { |attribute| CASA::Attribute::Loader.load! attribute }
          CASA::Attribute::Loader.loaded

        end

        def process payload

          payload_hash = adj_in_translate_strategy.execute payload
          adj_in_squash_strategy.execute! payload_hash
          return false unless adj_in_filter_strategy.allows? payload_hash
          adj_in_transform_strategy.execute! payload_hash
          adj_in_store.create payload_hash if @adj_in_store
          payload_hash

        end

      end
    end
  end
end