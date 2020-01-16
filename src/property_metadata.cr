module Athena::Serializer::Metadata; end

struct Athena::Serializer::PropertyMetadata(IvarType)
  include Athena::Serializer::Metadata

  getter name : String
  getter value : IvarType

  def initialize(
    @name : String,
    @value : IvarType = nil
  )
  end
end
