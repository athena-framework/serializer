require "./visitor_interface"

abstract class Athena::Serializer::Visitors::DeserializationVisitorInterface < Athena::Serializer::Visitors::VisitorInterface
  abstract def prepare(data : IO | String)

  # abstract def visit(data : Number.class) : Nil
end
