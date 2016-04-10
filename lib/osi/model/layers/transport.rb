module Osi
  module Model
    module Layers
      module Transport
        autoload :Interface, 'osi/model/layers/transport/interface'
        autoload :Serial, 'osi/model/layers/transport/serial'
        autoload :Tcp, 'osi/model/layers/transport/tcp'

        def new_tcp_layer(ip, port, &proc)
          Tcp.new(ip, port, &proc)
        end

        def new_serial_layer(port, options = {}, &proc)
          Serial.new(port, options, &proc)
        end

        private_constant :Tcp, :Serial
      end
    end
  end
end