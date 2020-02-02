module Athena::Serializer::SerializerInterface
  abstract def serialize(data : _, format : ASR::Format, context : ASR::SerializationContext = ASR::SerializationContext.new, **named_args) : String
  abstract def serialize(data : _, format : ASR::Format, io : IO, context : ASR::SerializationContext = ASR::SerializationContext.new, **named_args) : Nil
  abstract def deserialize(type : ASR::Serializable.class, data : String | IO, format : ASR::Format, context : ASR::DeserializationContext = ASR::DeserializationContext.new)
end
