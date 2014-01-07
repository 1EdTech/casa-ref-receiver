module CASA
  module Receiver
    module AdjInFilter
      class Strategy

        def self.factory attributes
          CASA::Receiver::AdjInFilter::Strategy.new attributes
        end

        attr_reader :attributes

        def initialize attributes
          @attributes = attributes
        end

        def allows? payload_hash

          passes = true
          @attributes.each do |attribute_name, attribute|
            passes = passes and attribute.filter payload_hash
          end
          passes

        end

      end
    end
  end
end