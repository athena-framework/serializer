# The `ASR::Context` specific to deserialization.
#
# Allows specifying if `nil` values should be serialized.
class Athena::Serializer::SerializationContext < Athena::Serializer::Context
  # If `nil` values should be serialized.
  property? emit_nil : Bool = false
end
