require 'rs_232'

module Osi
  module Model
    module Layers
      module Transport
        class Serial < Interface
          attr_reader :interface

          def initialize(port, options = {}, &block)
            @port = port
            @interface = CommPort::Rs232.new(port)
            @options = options
            @baud_rate = options.fetch(:baud_rate) { CommPort::BAUD_115200 }.to_i
            @data_bits = options.fetch(:data_bits) { CommPort::DATA_BITS_8 }.to_i
            @parity = options.fetch(:parity) { CommPort::PAR_NONE }.to_i
            @stop_bits = options.fetch(:stop_bits) { CommPort::STOP_BITS_1 }.to_i
            @flow_control = options.fetch(:flow_control) { CommPort::FLOW_OFF }.to_i
            @options = options.dup
            super(&block)
          end

          public def connect(timeout)
            if @interface.respond_to?(:connecting_timeout)
              @interface.connecting_timeout = timeout
            end
            @interface.open

            @interface.baud_rate = @baud_rate
            @interface.data_bits = @data_bits
            @interface.parity = @parity
            @interface.stop_bits = @stop_bits
            @interface.flow_control = @flow_control

            spawn_new_read_thread.
                connected?
          rescue Exception => ex
            abort(ex.message)
          end

          public def disconnect
            flush
            join_read_thread!
            @interface.close
            !connected?
          end

          # @return [Bool]
          #
          def connected?
            @interface && !@interface.closed?
          end

          def push_down(bytes)
            write(bytes)
          end

          private def flush
            @interface.flush
          end

          private def write(bytes)
            fail Errors::NotConnectedError unless connected?
            @interface.write(bytes)
          end

          # == read() implementation example
          #
          # @param count [Int]
          # @param blocking [Bool]
          #
          # @return [String]
          #
          # === Alternative implementation:
          # usage:
          #
          #  timeout = blocking_value ? 15000 : 0
          #  interface.timeout = timeout
          #
          # Example:
          #  interface.read( 10 ) #=> '1111111111'
          #
          private def read(count, blocking = false)
            fail Errors::NotConnectedError unless connected?

            array = []

            bytes_count = (count == -1) ? @interface.available? : count

            if blocking
              bytes = read_io_until(count, count)
              array.push bytes if bytes
            else
              bytes_count.times do
                byte = @interface.read(1)
                array.push byte if byte
              end
            end
            array.empty? ? nil : array.join
          end

          # == simulate blocking function
          #
          # @param [Fixnum] count
          # @param [Int] up_to
          #
          # no direct ruby usage
          #
          private def block_io_until(count, up_to)
            up_to -= 1 while @interface.available? < count && up_to > 0
            up_to > 0
          end

          # == simulate blocking function
          #
          # @param [Int] count
          # @param [Int] up_to
          #
          # no direct ruby usage
          #
          private def read_io_until(count, up_to)
            sleep 0.001 until block_io_until(count, up_to)
            read(count)
          end
        end
      end
    end
  end
end