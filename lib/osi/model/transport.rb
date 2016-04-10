require 'functional'

module Osi
  module Model
    class Transport < Layer
      include Osi::Model::Logging

      def initialize(&block)
        @listener = block_given? ? block : -> (_) {}
        Thread.abort_on_exception = true
        @reading = false
        @listener_thread = Functional::Option.none
      end

      def receive(chunk)
        raise new Errors::UnsupportedOperationException('Cannot handle #receive. I am tail node in the stack.')
      end

      def connect(_timeout)
        fail Errors::MustBeImplementedError
      end

      def disconnect
        fail Errors::MustBeImplementedError
      end

      def connected?
        fail Errors::MustBeImplementedError
      end

      private def read(amount, wait_indefinitely)
        fail Errors::MustBeImplementedError
      end

      private def reading_allowed?
        @reading
      end

      private def allow_reading!
        @reading = true
      end

      private def defer_reading!
        @reading = false
      end

      private def join_read_thread!
        return unless @listener_thread.some?
        defer_reading!
        @listener_thread.some.join
        @listener_thread = Option.none
        self
      end

      private def spawn_new_read_thread
        @listener_thread.some.kill if @listener_thread.some?
        @listener_thread = Option.some(spawn_read_thread @listener)
        self
      end

      private def spawn_read_thread(proc)
        fail NotConnectedError unless connected?
        allow_reading!

        Thread.new do
          while reading_allowed? && connected?
            begin
              data = read(1000, false)
              proc.(data) if data
              sleep(0.01)
            rescue => ex
              error "#{ex.class} occurred in RX thread."
            end
          end
        end
      end
    end
  end
end
