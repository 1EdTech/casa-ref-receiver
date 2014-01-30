require 'casa/receiver/strategy/base_with_attributes'

module CASA
  module Receiver
    module Strategy
      class AdjInSquash < BaseWithAttributes

        attribute_method :in_squash

        def execute! payload_hash

          payload_hash['attributes'] = {
            'uri' => payload_hash['original']['uri'],
            'timestamp' => payload_hash['original']['timestamp'],
            'share' => payload_hash['original']['share'],
            'propagate' => payload_hash['original']['propagate'],
            'use' => {},
            'require' => {}
          }

          execute_attribute_method_over_attributes! payload_hash, 'attributes'

        end

      end
    end
  end
end