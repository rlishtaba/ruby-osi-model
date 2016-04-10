require 'functional'

module Osi
  module Model
    module Layers
      class Layer
        include Functional

        module Errors
          RuntimeError = Class.new(RuntimeError)
          UpperLayerIsUndefined = Class.new(RuntimeError)
          LowerLayerIsUndefined = Class.new(RuntimeError)
          UnsupportedOperationException = Class.new(RuntimeError)
          MustBeImplementedError = Class.new(RuntimeError)
          NotConnectedError = Class.new(RuntimeError)
        end

        def initialize
          @upper_layer = Option.none
          @lower_layer = Option.none
        end

        attr_accessor :lower_layer

        def link_with(upper_layer)
          @upper_layer = Option.some upper_layer
          upper_layer.lower_layer = Option.some self
          upper_layer
        end

        def swim(chunk)
          try_to_swim { |l|
            l.receive chunk
          }
        end

        def sink(chunk)
          try_to_sink { |l| l.push_down chunk }
        end

        def receive(_chunk)
          raise Errors::MustBeImplementedError
        end

        def push_down(_chunk)
          raise Errors::MustBeImplementedError
        end

        private

        def try_to_swim(&functor)
          @upper_layer.some? ? functor.(@upper_layer.some) : fail(Errors::UpperLayerIsUndefined)
        end

        def try_to_sink(&functor)
          @lower_layer.some? ? functor.(@lower_layer.some) : fail(Errors::LowerLayerIsUndefined)
        end
      end
    end
  end
end
