require 'rest_client'

module CASA
  module Receiver
    module ReceiveIn
      class ResponseError < RestClient::Exception
        def initialize rest_client_exception
          @response = rest_client_exception.response
          @message = rest_client_exception.http_body
          @initial_response_code = rest_client_exception.http_code
        end
      end
    end
  end
end