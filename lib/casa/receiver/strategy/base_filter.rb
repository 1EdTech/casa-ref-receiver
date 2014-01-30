require 'casa/receiver/strategy/base_with_attributes'

module CASA
  module Receiver
    module Strategy
      class BaseFilter < BaseWithAttributes

        def allows? payload_hash
          reduce_attributes_with_attribute_method! payload_hash, nil
        end

      end
    end
  end
end