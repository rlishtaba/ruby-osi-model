require 'osi/model/version'
require 'logger'

module Osi
  module Model
    autoload :Layer, 'osi/model/layer'
    autoload :Transport, 'osi/model/transport'
    autoload :Serial, 'osi/model/serial'
    autoload :Tcp, 'osi/model/tcp'
    autoload :Logging, 'osi/model/logging'

    class << self
      def logger
        @logger ||= Logger.new $stdout
      end
    end
  end
end
