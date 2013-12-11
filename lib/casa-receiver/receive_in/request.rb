require 'rest_client'
require 'json'

module CASA
  module Receiver
    module ReceiveIn
      module Request

        def self.headers custom_headers = nil

          default_headers = {
            'Accept' => 'application/json',
            'Accept-Charset' => 'utf-8',
            'Content-Type' => 'application/json'
          }

          if custom_headers
            default_headers.merge custom_headers
          else
            default_headers
          end

        end

        def self.route server_path, options = nil

          "#{server_path.gsub /\/$/, ''}/payloads"

        end

        def self.body data

          begin
            JSON.parse data
            data
          rescue TypeError
            data.to_json
          rescue JSON::ParserError
            data.to_json
          end

        end

      end
    end
  end
end

