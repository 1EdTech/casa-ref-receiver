require 'thor'
require 'yaml'
require 'pathname'
require 'casa-attribute/loader_attribute_error'
require 'casa-attribute/loader_class_error'
require 'casa-attribute/loader_file_error'
require 'casa-receiver/client/strategy'
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
          strategy = CASA::Receiver::Client::Strategy.new server_url, strategy_options
          puts strategy.processed_payloads.to_json
        rescue CASA::Attribute::LoaderAttributeError
          say_fail "All attributes must define name and class\nPlease resolve issues in attribute configuration"
        rescue CASA::Attribute::LoaderFileError => e
          say_fail "Attribute class '#{e.class_name}' requires the load path `#{e.require_path}`\nPlease add a gem to `Gemfile` that defines this load path"
        rescue CASA::Attribute::LoaderClassError => e
          say_fail "Load path '#{e.require_path}' does not define expected class `#{e.class_name}`\nPlease resolve this error by fixing the class to load path mapping"
        rescue CASA::Receiver::ReceiveIn::BodyStructureError
          say_fail 'Server responded with body that is not a JSON array'
        rescue CASA::Receiver::ReceiveIn::BodyParserError
          say_fail 'Server responded with body that does not parse as JSON'
        rescue CASA::Receiver::ReceiveIn::RequestError => e
          say_fail e.message, :red
        rescue CASA::Receiver::ReceiveIn::ResponseError => e
          say_fail "Server responded with error #{e.http_code}"
        end

      end

      no_commands do

        def say_fail message
          say message, :red
          exit 1
        end

        def strategy_options
          options.to_hash.merge({
              'attributes' => JSON.parse(File.read @base_path + 'attributes.json')
          })
        end

      end

    end
  end
end