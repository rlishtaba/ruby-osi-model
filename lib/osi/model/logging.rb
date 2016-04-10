module Osi
  module Model
    module Logging
      def debug(message)
        logger.debug(message)
      end

      def error(message)
        logger.error(message)
      end

      private def logger
        Osi::Model.logger
      end
    end
  end
end
