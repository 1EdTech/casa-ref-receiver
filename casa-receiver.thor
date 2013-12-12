require 'casa-receiver'
require 'casa-attribute/loader'
require 'casa-attribute/loader_file_error'
require 'casa-attribute/loader_class_error'

class Receiver < Thor

  desc 'get_payloads', 'Query a host for payloads'

  def get_payloads

    attributes = [
        { 'name' => 'title', 'class' => 'CASA::Attribute::Title', 'path' => 'casa-attribute/title', 'options' => {} }
    ]

    begin
      attributes.each { |attribute| CASA::Attribute::Loader.load! attribute }
    rescue CASA::Attribute::LoaderAttributeError
      abort "\e[31m\e[1mAll attributes must define name and class\e[0m\n\e[31mPlease resolve issues in attribute configuration"
    rescue CASA::Attribute::LoaderFileError => e
      abort "\e[31m\e[1mAttribute class '#{e.class_name}' requires the load path `#{e.require_path}`\e[0m\n\e[31mPlease add a gem to `Gemfile` that defines this load path"
    rescue CASA::Attribute::LoaderClassError => e
      abort "\e[31m\e[1mLoad path '#{e.require_path}' does not define expected class `#{e.class_name}`\e[0m\n\e[31mPlease resolve this error by fixing the class to load path mapping"
    end

    adj_in_translate_strategy = CASA::Receiver::AdjInTranslate::Strategy.new
    CASA::Attribute::Loader.loaded.each do |attribute_name, attribute|
      adj_in_translate_strategy.map attribute.uuid => attribute_name
    end

    client = CASA::Receiver::ReceiveIn::Client.new

    server_url = ask('Server URL (required):').strip
    client.use_server_url server_url unless server_url.length == 0

    secret = ask('Secret (optional - blank to skip):').strip
    client.use_secret secret unless secret.length == 0

    say ''
    begin
      payloads = CASA::Receiver::ReceiveIn::PayloadFactory.from_response client.get_payloads
      payloads.each do |payload|
        say payload.to_json, :cyan
        payload_hash = adj_in_translate_strategy.execute(payload)
        payload_hash['attributes'] = {
          'originator_id' => payload_hash['identity']['originator_id'],
          'timestamp' => 'TIMESTAMP',
          'share' => payload_hash['original']['share'],
          'propagate' => payload_hash['original']['propagate'],
          'use' => {},
          'require' => {}
        }
        CASA::Attribute::Loader.loaded.each do |attribute_name, attribute|
          payload_hash['attributes'][attribute.section][attribute_name] = attribute.squash payload_hash
        end
        say payload_hash, :green
      end
    rescue CASA::Receiver::ReceiveIn::BodyStructureError
      say 'Server responded with body that is not a JSON array', :red
    rescue CASA::Receiver::ReceiveIn::BodyParserError
      say 'Server responded with body that does not parse as JSON', :red
    rescue CASA::Receiver::ReceiveIn::RequestError => e
      say e.message, :red
    rescue CASA::Receiver::ReceiveIn::ResponseError => e
      say "Server responded with error #{e.http_code}", :red
    end

    if yes? "Run another query ('y' to continue)?", :magenta
      say ''
      get_payloads
    end

  end

end