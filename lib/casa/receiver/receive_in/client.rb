require 'rest_client'
require 'casa/receiver/receive_in/request_error'
require 'casa/receiver/receive_in/response_error'
require 'casa/receiver/receive_in/request'

module CASA
  module Receiver
    module ReceiveIn
      class Client

        def initialize server_url = false, client_secret = false

          use_server_url server_url
          use_secret client_secret

        end

        def use_server_url server_url

          @server_url = server_url

        end

        def use_secret client_secret = false

          @client_secret = client_secret

        end

        def get_payloads options = nil

          raise RequestError.new('Server URL must be specified') unless @server_url

          request_body = {}
          request_body['secret'] = @client_secret if @client_secret

          begin
            RestClient::Request.execute({
              :method => :get,
              :url => Request::route(@server_url),
              :headers => Request::headers,
              :payload => Request::body(request_body)
            })
          rescue RestClient::Exception => rest_client_exception
            raise ResponseError.new rest_client_exception
          end

        end

      end
    end
  end
end

