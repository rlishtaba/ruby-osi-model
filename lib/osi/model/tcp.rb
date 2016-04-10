require 'socket'
require 'timeout'
require 'functional'

module Osi
  module Model
    class Tcp < Transport
      attr_reader :ip, :port, :interface
      include Socket::Constants
      include Osi::Model::Logging

      # timeout is in seconds. If set to 0, there is no timeout.
      def initialize(ip, port, options = {}, &block)
        @options = options
        @connecting_timeout = @options.fetch(:connecting_timeout) { 15 }.to_i
        @sending_timeout = @options.fetch(:sending_timeout) { 5 }.to_i
        @receiving_timeout = @options.fetch(:receiving_timeout) { 60 }.to_i
        @ip = ip
        @port = port
        super(&block)
      end

      def connect(timeout)
        return if connected?
        @interface = Socket.new(AF_INET, SOCK_STREAM, 0)
        @interface.setsockopt(IPPROTO_TCP, TCP_NODELAY, 1)
        connect_nonblock(Socket.pack_sockaddr_in(port, ip))
        spawn_new_read_thread
            .connected?
      rescue Timeout::Error
        abort
      end

      def connected?
        @interface && !@interface.closed?
      end

      def disconnect
        return !connected? unless connected?
        join_read_thread!
        flush
        @interface.close
        !connected?
      end

      def push_down(bytes)
        fail Errors::NotConnectedError unless connected?
        debug "writing out to the stream: #{bytes.inspect}"
        write(bytes)
      end

      private

      def flush
        @interface.flush
      end

      def write(message)
        @interface.write message
      end

      def recv_nonblock(count)
        @interface.recv_nonblock count
      end

      def read(count, wait_indefinitely = false)
        recv = recv_nonblock count
        return recv
      rescue IO::WaitReadable
        if wait_indefinitely
          IO.select [@interface]
          retry
        end
      end

      def connect_nonblock(endpoint)
        @interface.connect_nonblock(endpoint)
      rescue Errno::EINPROGRESS
        if IO.select(nil, [@interface], nil, @connecting_timeout)
          retry
        else
          raise Timeout::Error
        end
      rescue Errno::EISCONN
        @interface
      end
    end
  end
end
