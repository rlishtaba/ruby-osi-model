#
# this is playground space. Not for production usage
#
#
module Osi
  module Model
    module Layers
      module Protocols
        class Bisync < Osi::Model::Layers::Layer
          include Osi::Model::Logging

          InvalidLRC = Class.new(RuntimeError)
          MessageTooShort = Class.new(RuntimeError)

          WAITING_STX = 0
          WAITING_ETX = 1
          WAITING_LRC = 2
          WAITING_ACKNOWLEDGE = 3

          CONTROL_CHARS = {
              stx: 0x02.chr,
              etx: 0x03.chr,
              ack: 0x06.chr,
              nack: 0x15.chr
          }.freeze

          def initialize
            @state = transition_to WAITING_STX
            @buffer = []
          end

          def receive(chunk)
            chunk.chars.each { |byte|
              receive_byte(byte)
            }
          end

          def push_down(bytes)
            debug "#{self.class}: pushing down the following: #{bytes.inspect}"
            sink make_packet_from(bytes)
          end

          private

          def make_packet_from(bytes)
            add_lrc(CONTROL_CHARS[:stx] + bytes + CONTROL_CHARS[:etx])
          end

          def receive_byte(byte)
            if waiting_stx?
              if stx? byte
                @buffer.clear
                transition_to WAITING_ETX
              end
            elsif waiting_etx?
              if etx? byte
                transition_to WAITING_LRC
              else
                @buffer.push byte
              end
            elsif waiting_acknowledge?
              if ack? byte
                debug "#{self.class}: ACK received: #{byte.inspect}"
                transition_to WAITING_STX
              elsif nack? byte
                debug "#{self.class}: NACK received: #{byte.inspect}"
                # todo: ARQ strategy with window=1 required
                # transition_to WAITING_STX
              else
                debug "#{self.class}: ignoring byte: #{byte.inspect}"
              end
            else
              if valid_lrc?(byte, @buffer.join.freeze)
                swim(@buffer.join)
                @buffer.clear
                sink_ack
              else
                sink_nack
              end
              transition_to WAITING_STX
            end
          end

          def sink_ack
            debug('dispatching ACK')
            sink CONTROL_CHARS[:ack]
          end

          def sink_nack
            debug('dispatching NACK')
            sink CONTROL_CHARS[:nack]
          end

          def transition_to(new_state)
            debug("#{self.class}: transition to state: #{new_state}")
            @state = new_state
          end

          def add_lrc(message)
            message + lrc(message)
          end

          def valid_lrc?(lrc_byte, bytes)
            message = CONTROL_CHARS[:stx] + bytes + CONTROL_CHARS[:etx]
            lrc(message.force_encoding('US-ASCII')) == lrc_byte
          end

          def lrc(message)
            message_bytes = message.bytes.to_a
            fail MessageTooShort, message if message_bytes.length < 2
            result = message_bytes[1]
            message_bytes[2..-1].each do |byte|
              result ^= byte
            end
            result.chr
          end

          def waiting_stx?
            WAITING_STX == @state
          end

          def waiting_etx?
            WAITING_ETX == @state
          end

          def waiting_lrc?
            WAITING_LRC== @state
          end

          def waiting_acknowledge?
            WAITING_ACKNOWLEDGE == @state
          end

          def ack?(b)
            CONTROL_CHARS[:ack] == b
          end

          def nack?(b)
            CONTROL_CHARS[:nack] == b
          end

          def stx?(b)
            CONTROL_CHARS[:stx] == b
          end

          def etx?(b)
            CONTROL_CHARS[:etx] == b
          end
        end
      end
    end
  end
end
