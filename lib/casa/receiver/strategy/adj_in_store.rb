module CASA
  module Receiver
    module Strategy
      class AdjInStore

        def self.factory options = false
          options ? self.new(options) : nil
        end

        attr_reader :options

        def initialize options
          @options = options
          if @options.has_key?('class') and @options.has_key?('require')
            require @options['require']
            class_object = @options['class'].split('::').inject(Object){|o,c| o.const_get c}
            @handler = class_object.new @options['options']
          elsif @options.has_key?('handler')
            @handler = @options['handler']
          end
        end

        def create payload_hash, options = nil
          identity = payload_hash['identity']
          current = get identity
          if current
            return false if payload_hash['attributes']['timestamp'] <= current['attributes']['timestamp']
            delete identity
          end
          @handler.create payload_hash, options
          true
        end

        def get payload_identity, options = nil
          @handler.get payload_identity, options
        end

        def delete payload_identity, options = nil
          @handler.delete payload_identity, options
        end

        def reset! options = nil
          @handler.reset! options
        end

      end
    end
  end
end