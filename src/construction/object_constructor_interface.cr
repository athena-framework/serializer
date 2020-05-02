module Athena::Serializer::ObjectConstructorInterface
  abstract def construct(navigator : ASR::Navigators::DeserializationNavigator, properties : Array(PropertyMetadataBase), data : ASR::Any, type)
end
