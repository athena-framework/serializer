module Athena::Serializer::SerializerInterface
  abstract def serialize(data : _, format : ASR::Format, io : IO) : Nil
  abstract def serialize(data : _, format : ASR::Format) : String
  # abstract def deserialize(data : String | IO, format : ASR::Format.class) : _
end
