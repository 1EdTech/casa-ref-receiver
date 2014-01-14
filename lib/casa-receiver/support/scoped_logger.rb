module CASA
  module Receiver
    module Support
      class ScopedLogger < SimpleDelegator

        attr_accessor :scope

        def initialize object, starting_scope = nil
          super object
          @scope = starting_scope
        end

        def block name = nil, &block
          yield ScopedLogger.new __getobj__, @scope ? "#{@scope} - #{name}" : name
        end

        [:debug, :error, :fatal, :info, :warn].each do |method|
          define_method(method) { |message| __getobj__.send(method, @scope) { message } }
        end

      end
    end
  end
end
