require 'casa-receiver'
require 'casa-attribute/loader'
require 'casa-attribute/loader_file_error'
require 'casa-attribute/loader_class_error'
require 'optparse'

class Casa < Thor

  desc 'receive SERVER_URL', 'Query an adjacent CASA engine for payloads'

  method_option :secret, :aliases => '-s', :desc => 'Secret to send with GET /payloads request'

  def receive server_url

    prepare_client! server_url, options

    prepare_attributes! options

    begin
      payloads = CASA::Receiver::ReceiveIn::PayloadFactory.from_response @client.get_payloads
      payloads.each do |payload|
        say payload.to_json, :cyan
        payload_hash = process_payload payload
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

  end

  private

  def prepare_client! server_url, options

    @client = CASA::Receiver::ReceiveIn::Client.new server_url
    @client.use_secret options['secret'] if options.has_key? 'secret'

  end

  def prepare_attributes! options

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

    @attributes = CASA::Attribute::Loader.loaded

  end

  def process_payload payload

    payload_hash = translate_payload payload
    squash_payload_attributes payload_hash
    payload_hash

  end

  def translate_payload payload

    adj_in_translate_strategy = CASA::Receiver::AdjInTranslate::Strategy.new
    @attributes.each do |attribute_name, attribute|
      adj_in_translate_strategy.map attribute.uuid => attribute_name
    end

    adj_in_translate_strategy.execute payload

  end

  def squash_payload_attributes_base payload_hash

    payload_hash['attributes'] = {
      'originator_id' => payload_hash['identity']['originator_id'],
      'timestamp' => 'TIMESTAMP',
      'share' => payload_hash['original']['share'],
      'propagate' => payload_hash['original']['propagate'],
      'use' => {},
      'require' => {}
    }

  end

  def squash_payload_attributes payload_hash

    squash_payload_attributes_base payload_hash

    @attributes.each do |attribute_name, attribute|
      payload_hash['attributes'][attribute.section][attribute_name] = attribute.squash payload_hash
    end

  end


end