require 'casa-receiver/receive_in/client'
require 'casa-receiver/receive_in/payload_factory'
require 'casa-receiver/strategy/payload'
require 'casa-receiver/support/scoped_logger'

module CASA
  module Receiver
    module Strategy
      class Client

        attr_reader :server_url
        attr_reader :options

        def initialize server_url, options

          @server_url = server_url
          @options = options

          @client = CASA::Receiver::ReceiveIn::Client.new server_url
          @client.use_secret options['secret'] if options.has_key? 'secret'

          @payload_strategy = CASA::Receiver::Strategy::Payload.new options.merge({'client'=>server_url})

          @logger = CASA::Receiver::Support::ScopedLogger.new(
            @options.has_key?('logger') ? @options['logger'] : ::Logger.new('/dev/null'),
            server_url
          )

          reset!

        end

        def execute!
          @processed_payloads = raw_payloads.map { |payload| @payload_strategy.process payload }
        end

        def raw_payloads
          @logger.info "Querying client for payloads"
          @raw_payloads ||= CASA::Receiver::ReceiveIn::PayloadFactory.from_response @client.get_payloads
        end

        def processed_payloads
          @processed_payloads || execute!
        end

        def reset!
          @raw_payloads = nil
          @processed_payloads = nil
        end

      end
    end
  end
end