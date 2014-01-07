require 'thor'
require 'yaml'
require 'json'
require 'pathname'
require 'casa-attribute/loader_attribute_error'
require 'casa-attribute/loader_class_error'
require 'casa-attribute/loader_file_error'
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

      class_option  :settings,
                    :type => :string,
                    :default => Pathname.new(__FILE__).parent.parent.parent + 'settings.json',
                    :desc => 'Path to settings file'

      desc 'reset', 'Reset persistence layer maintained by receiver'

      def reset

        adj_in_store = CASA::Receiver::Strategy::AdjInStore.factory strategy_options['persistence']
        adj_in_store.reset! if adj_in_store

      end

      desc 'get SERVER_URL', 'Issue a query against a CASA Publisher'

      method_option :secret,
                    :type => :string,
                    :desc => 'Secret to send with GET /payloads request'

      method_option :output,
                    :type => :string,
                    :enum => ['json','yaml','none'],
                    :default => 'json',
                    :desc => 'Output format'

      method_option :store,
                    :type => :boolean,
                    :default => false,
                    :desc => 'Store result in persistence'

      def get server_url

        begin
          strategy = CASA::Receiver::Strategy::Client.new server_url, strategy_options
          say_output strategy.processed_payloads
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
          say_fail e.message
        rescue CASA::Receiver::ReceiveIn::ResponseError => e
          say_fail "Server responded with error #{e.http_code}"
        end

      end

      no_commands do

        def say_output payloads
          case options['output']
            when 'json'
              say payloads.to_json
            when 'yaml'
              say payloads.to_yaml
          end
        end

        def say_fail message
          say message, :red unless options['output'] == 'none'
          exit 1
        end

        def strategy_options
          unless @strategy_options
            @strategy_options = JSON.parse(File.read options['settings']).merge options.to_hash
            @strategy_options['persistence'] = false unless options['store']
          end
          @strategy_options
        end

      end

    end
  end
end