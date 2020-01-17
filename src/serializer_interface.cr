module Athena::Serializer::SerializerInterface
  abstract def serialize(data : _, format : ASR::Format, io : IO, **named_args) : Nil
  abstract def serialize(data : _, format : ASR::Format, **named_args) : String
  # abstract def deserialize(data : String | IO, format : ASR::Format.class) : _
end
