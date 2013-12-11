require 'casa-receiver/receive_in'

class Receiver < Thor

  desc 'get_payloads', 'Query a host for payloads'

  def get_payloads

    client = CASA::Receiver::ReceiveIn::Client.new

    server_url = ask('Server URL (required):').strip
    client.use_server_url server_url unless server_url.length == 0

    secret = ask('Secret (optional - blank to skip):').strip
    client.use_secret secret unless secret.length == 0

    begin
      payloads = CASA::Receiver::ReceiveIn::PayloadFactory.from_response client.get_payloads
      payloads.each { |payload| say payload.to_json, :green }
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
      get_payloads
    end

  end

end