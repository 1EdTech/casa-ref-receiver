require 'thor'
require 'casa-receiver/strategy/client'
require 'casa-receiver/receive_in/body_parser_error'
require 'casa-receiver/receive_in/body_structure_error'
require 'casa-receiver/receive_in/request_error'
require 'casa-receiver/receive_in/response_error'

module CASA
  module Receiver

    class Thor < ::Thor

      def initialize args = [], options = {}, config = {}
        super args, options, config
      end

      desc 'query SERVER_URL', 'Issue a query against a CASA Publisher'
      method_option :secret, :aliases => '-s', :desc => 'Secret to send with GET /payloads request'
      def query server_url

        strategy_options = options.to_hash.merge({
            'attributes' => [
              {
                'name' => 'title',
                'class' => 'CASA::Attribute::Title',
                'options' => {
                  'transform' => [
                    {
                      'method' => 'identity_map',
                      'identity_map' => {
                        '1f262086-615f-11e3-bf13-d231feb1dc81:ex2' => 'Sample Application 2 (transformed)',
                        '1f262087-615f-11e3-bf13-d231feb1dc81:prop1' => 'Sample Application 3 (propagated) (transformed)'
                      }
                    }
                  ]
                }
              }
            ]
        })

        strategy = CASA::Receiver::Strategy::Client.new server_url, strategy_options

        begin
          puts strategy.processed_payloads.to_json
        rescue CASA::Receiver::ReceiveIn::BodyStructureError
          say 'Server responded with body that is not a JSON array', :red
        rescue CASA::Receiver::ReceiveIn::BodyParserError
          say 'Server responded with body that does not parse as JSON', :red
        rescue CASA::Receiver::ReceiveIn::RequestError => e
          say e.message, :red
        rescue CASA::Receiver::ReceiveIn::ResponseError => e
          say "Server responded with error #{e.http_code}", :red
        end

      end

    end
  end
end