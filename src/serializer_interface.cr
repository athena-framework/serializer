module Athena::Serializer::SerializerInterface
  abstract def serialize(data : _, format : ASR::Format | String, context : ASR::SerializationContext = ASR::SerializationContext.new, **named_args) : String
  abstract def serialize(data : _, format : ASR::Format | String, io : IO, context : ASR::SerializationContext = ASR::SerializationContext.new, **named_args) : Nil
  abstract def deserialize(type : ASR::Serializable.class, data : String | IO, format : ASR::Format | String, context : ASR::DeserializationContext = ASR::DeserializationContext.new)
end
