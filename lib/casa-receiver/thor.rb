require 'thor'
require 'yaml'
require 'pathname'
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
        @base_path = Pathname.new(__FILE__).parent.parent.parent
      end

      desc 'query SERVER_URL', 'Issue a query against a CASA Publisher'

      method_option :secret, :aliases => '-s', :desc => 'Secret to send with GET /payloads request'

      def query server_url

        begin
          strategy = CASA::Receiver::Strategy::Client.new server_url, strategy_options
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

      no_commands do

        def strategy_options
          options.to_hash.merge({
              'attributes' => JSON.parse(File.read @base_path + 'attributes.json')
          })
        end

      end

    end
  end
end