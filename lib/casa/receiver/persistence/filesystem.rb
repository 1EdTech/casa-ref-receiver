require 'fileutils'
require 'json'
require 'casa/payload/local_payload'

module CASA
  module Receiver
    module Persistence
      class Filesystem

        attr_reader :options

        def initialize options = nil
          @options = options
          @base_dir = Pathname.new(__FILE__).parent.parent.parent.parent.parent + (options.has_key?('directory') ? options['directory'] : 'data')
          FileUtils.mkdir_p @base_dir
        end

        def create payload_hash, options = nil
          path = file_path payload_hash['identity']
          raise 'Cannot create over existing payload' if File.exists? path
          FileUtils.mkdir_p path.parent
          File.open(path, 'w'){ |file| file.write CASA::Payload::LocalPayload.new(payload_hash).to_json }
        end

        def get payload_identity, options = nil
          path = file_path payload_identity
          File.exists?(path) ? CASA::Payload::LocalPayload.new(JSON.parse File.read path) : false
        end

        def delete payload_identity, options = nil
          path = file_path payload_identity
        end

        def reset! options = nil
          FileUtils.rm_rf @base_dir
        end

        def file_path identity
          @base_dir + identity['originator_id'] + "#{identity['id']}.json"
        end

      end
    end
  end
end