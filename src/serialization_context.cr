# Stores runtime data about the current serialization action.
class Athena::Serializer::SerializationContext < Athena::Serializer::Context
  property? emit_nil : Bool = false
end

class Athena::Serializer::DeserializationContext < Athena::Serializer::Context
end
