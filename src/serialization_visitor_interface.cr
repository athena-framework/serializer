abstract struct Athena::Serializer::SerializationVisitorInterface
  abstract def initialize(io : IO) : Nil

  # Accept and serialize the provided *properties*.
  #
  # This overload is intended for `ASR::Serializable` types.
  abstract def accept(properties : Array(Metadata)) : Nil

  # Accept and serialize the provided *data*.
  #
  # This overload is intended to support primitive types.
  abstract def accept(data : _) : Nil

  abstract def visit(data : Nil) : Nil
  abstract def visit(data : String) : Nil
  abstract def visit(data : Number) : Nil
  abstract def visit(data : Bool) : Nil
  abstract def visit(data : Array | Set | Deque | Tuple) : Nil
  abstract def visit(data : Hash) : Nil
  abstract def visit(data : Serializable) : Nil
end
