module CASA
  module Receiver
    module Strategy
      class AdjInFilter

        def self.factory attributes
          CASA::Receiver::Strategy::AdjInFilter.new attributes
        end

        attr_reader :attributes

        def initialize attributes
          @attributes = attributes
        end

        def allows? payload_hash

          allows = true
          @attributes.each do |attribute_name, attribute|
            if attribute.respond_to? :filter
              unless attribute.filter payload_hash
                allows = false
                break
              end
            end
          end
          allows

        end

      end
    end
  end
end