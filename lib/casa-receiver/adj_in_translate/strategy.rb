require 'casa-operation/translate'

module CASA
  module Receiver
    module AdjInTranslate
      class Strategy < CASA::Operation::Translate::Strategy

        def execute payload

          payload_hash = payload.to_hash

          ['use','require'].each do |type|

            if payload_hash['original'].include? type
              payload_hash['original'][type] = super payload_hash['original'][type]
            end

            if payload_hash.include? 'journal'
              payload_hash['journal'].each_index do |idx|
                if payload_hash['journal'][idx].include? type
                  payload_hash['journal'][idx][type] = super payload_hash['journal'][idx][type]
                end
              end
            end

          end

          payload_hash

        end

      end
    end
  end
end