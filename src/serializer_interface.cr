module Athena::Serializer::SerializerInterface
  abstract def serialize(data : _, format : ASR::Format, io : IO, *, context : ASR::SerializationContext = ASR::SerializationContext.new, **named_args) : Nil
  abstract def serialize(data : _, format : ASR::Format, *, context : ASR::SerializationContext = ASR::SerializationContext.new, **named_args) : String
  # abstract def deserialize(data : String | IO, format : ASR::Format.class) : _
end
