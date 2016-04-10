module Osi
  module Model
    module Layers
      module Protocols
        autoload :Bisync, 'osi/model/layers/protocols/bisync'

        def new_bisync_layer
          Bisync.new
        end
      end
    end
  end
end
