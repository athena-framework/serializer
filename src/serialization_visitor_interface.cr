module Athena::Serializabe::SerializationVisitorInterface
  abstract def visit(data : Nil) : Nil
  abstract def visit(data : String) : Nil
  abstract def visit(data : Number) : Nil
  abstract def visit(data : Bool) : Nil
  abstract def visit(data : Array | Set | Deque | Tuple) : Nil
  abstract def visit(data : Hash) : Nil
  abstract def visit(data : Serializable) : Nil
end
