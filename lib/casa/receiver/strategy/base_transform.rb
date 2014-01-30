require 'casa/receiver/strategy/base_with_attributes'

module CASA
  module Receiver
    module Strategy
      class BaseTransform < BaseWithAttributes

        def execute! payload_hash
          execute_attribute_method_over_attributes! payload_hash, 'attributes'
        end

      end
    end
  end
end