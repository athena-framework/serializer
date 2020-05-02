require "./object_constructor_interface"

struct Athena::Serializer::InstantiateObjectConstructor
  include Athena::Serializer::ObjectConstructorInterface

  def construct(navigator : ASR::Navigators::DeserializationNavigator, properties : Array(PropertyMetadataBase), data : ASR::Any, type)
    type.new navigator.as(ASR::Navigators::DeserializationNavigator), properties, data
  end
end
