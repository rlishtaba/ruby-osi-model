require 'osi/model/version'
require 'logger'

module Osi
  module Model
    autoload :Layers, 'osi/model/layers'
    autoload :Logging, 'osi/model/logging'

    class << self
      def logger
        @logger ||= Logger.new $stdout
      end
    end
  end
end
