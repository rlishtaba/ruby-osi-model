module Osi
  module Model
    module Layers
      autoload :Layer, 'osi/model/layers/layer'
      autoload :Transport, 'osi/model/layers/transport'
      autoload :Protocols, 'osi/model/layers/protocols'
    end
  end
end