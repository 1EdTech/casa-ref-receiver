require 'casa-payload/transit_payload'
require 'casa-receiver/receive_in/body_structure_error'
require 'casa-receiver/receive_in/body_parser_error'
require 'json'

module CASA
  module Receiver
    module ReceiveIn
      class PayloadFactory

        def self.from_response response

          payloads = []

          begin
            response_body = JSON.parse(response.body)
          rescue JSON::ParserError
            raise BodyParserError
          end

          unless response_body.is_a? Array
            raise BodyStructureError
          end

          response_body.each do |payload_hash|
            payload = CASA::Payload::TransitPayload.new(payload_hash)
            if payload.validates?
              payloads.push payload
            end
          end

          payloads

        end

      end
    end
  end
end