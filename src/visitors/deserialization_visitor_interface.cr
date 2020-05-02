module Athena::Serializer::Visitors::DeserializationVisitorInterface
  abstract def prepare(data : IO | String) : ASR::Any
end
