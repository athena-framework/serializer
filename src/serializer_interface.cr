module Athena::Serializer::SerializerInterface
  abstract def serialize(data : _, format : ASR::Format.class) : String
  # abstract def deserialize(data : String | IO, format : ASR::Format.class) : _
end
