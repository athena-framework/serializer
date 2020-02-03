module Athena::Serializer::Visitors::DeserializationVisitorInterface
  abstract def prepare(data : IO | String) : JSON::Any

  # abstract def visit(data : Number.class) : Nil
end
