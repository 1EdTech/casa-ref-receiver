module CASA
  module Receiver
    module Strategy
      class LoadFromAdjInStore

        def initialize options

          if options.has_key? 'attributes'
            options['attributes'].each { |attribute| CASA::Attribute::Loader.load! attribute }
          end

          @attributes = CASA::Attribute::Loader.loaded
          @from_handler = options['persistence']['from']['handler']
          @to_handler = options['persistence']['to']['handler']
          @transform_strategy = options['transform']['handler']

          @logger = options.has_key?('logger') ? options['logger'] : CASA::Support::ScopedLogger.new(null, '/dev/null')

        end

        def execute!

          @from_handler.get_all.each do |payload|

            @logger.scoped_block "#{payload['identity']['id']}@#{payload['identity']['originator_id']}" do |log|

              log.debug do
                @transform_strategy.execute! payload
                "Transforming payload"
              end

              log.debug do
                identity = payload['identity']
                current = @to_handler.get identity
                unless current and current['attributes']['timestamp'] >= payload['attributes']['timestamp']
                  @to_handler.delete current['identity'] if current
                  @to_handler.create payload
                  "Payload saved"
                else
                  "Payload not saved - already up-to-date"
                end
              end

            end

          end

        end

      end
    end
  end
end
