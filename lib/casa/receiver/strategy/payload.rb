require 'logger'
require 'casa/attribute/loader'
require 'casa/receiver/strategy/adj_in_translate'
require 'casa/receiver/strategy/adj_in_squash'
require 'casa/receiver/strategy/adj_in_filter'
require 'casa/receiver/strategy/adj_in_store'
require 'casa/support/scoped_logger'

module CASA
  module Receiver
    module Strategy

      class Payload

        attr_reader :options
        attr_reader :attributes
        attr_reader :adj_in_translate_strategy
        attr_reader :adj_in_squash_strategy
        attr_reader :adj_in_filter_strategy
        attr_reader :adj_in_store

        def initialize options

          @options = options
          @attributes = build_attribute_handlers @options['attributes']
          @adj_in_translate_strategy = CASA::Receiver::Strategy::AdjInTranslate.factory @attributes
          @adj_in_squash_strategy = CASA::Receiver::Strategy::AdjInSquash.factory @attributes
          @adj_in_filter_strategy = CASA::Receiver::Strategy::AdjInFilter.factory @attributes
          @adj_in_store = CASA::Receiver::Strategy::AdjInStore.factory @options['persistence']

          @logger = CASA::Support::ScopedLogger.new(
            @options.has_key?('client') ? @options['client'] : nil,
            @options.has_key?('logger') ? @options['logger'] : '/dev/null'
          )

        end

        def build_attribute_handlers attributes

          attributes.each { |attribute| CASA::Attribute::Loader.load! attribute }
          CASA::Attribute::Loader.loaded

        end

        def process payload

          @logger.scoped_block "#{payload['identity']['id']}@#{payload['identity']['originator_id']}" do |log|

            payload_hash = nil

            log.debug do
              payload_hash = adj_in_translate_strategy.execute payload
              "Translated payload"
            end

            log.debug do
              adj_in_squash_strategy.execute! payload_hash
              "Squashed payload"
            end

            allowed = true

            log.debug do
              allowed = adj_in_filter_strategy.allows? payload_hash
              "Filtered payload"
            end

            unless allowed
              log.info { "Dropped payload because filter failed" }
              return false
            end

            if @adj_in_store
              log.debug do
                adj_in_store.create payload_hash
                "Storing payload"
              end
            end

            payload_hash

          end

        end

      end
    end
  end
end