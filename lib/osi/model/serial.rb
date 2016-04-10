require 'rs_232'
require 'logger'

module Osi
  module Model
    class Serial < Transport
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
        debug "Trying to connect with timeout #{timeout.inspect}"

        if @interface.respond_to?(:connecting_timeout)
          @interface.connecting_timeout = timeout
        end

        @interface.open

        @interface.baud_rate = @baud_rate
        @interface.data_bits = @data_bits
        @interface.parity = @parity
        @interface.stop_bits = @stop_bits
        @interface.flow_control = @flow_control
        @connected = connected?
      rescue Exception => ex
        abort(ex.message)
      end

      public def disconnect
        flush
        @interface.close
        @connected = connected?
        !connected?
      end

      # @return [Bool]
      #
      public def connected?
        @interface && !@interface.closed?
      end

      public def push_down(bytes)
        fail Errors::NotConnectedError unless connected?
        debug "writing out to the stream: #{bytes.inspect}"
        self.write(bytes)
      end

      private def flush
        @interface.flush
      end

      private def write(bytes)
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

      private def debug(message)
                @logger ||= ::Logger.new($stdout)
                @logger.debug("[#{self.class}]: #{message}")

      end
    end
  end
end