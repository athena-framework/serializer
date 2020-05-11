module Athena::Serializer::ObjectConstructorInterface
  abstract def construct(navigator : ASR::Navigators::DeserializationNavigatorInterface, properties : Array(PropertyMetadataBase), data : ASR::Any, type)
end
