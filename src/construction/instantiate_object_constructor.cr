require "./object_constructor_interface"

struct Athena::Serializer::InstantiateObjectConstructor
  include Athena::Serializer::ObjectConstructorInterface

  def construct(navigator : ASR::Navigators::DeserializationNavigatorInterface, properties : Array(PropertyMetadataBase), data : ASR::Any, type)
    type.deserialize navigator, properties, data
  end
end
