module Athena::Serializer::Navigators::DeserializationNavigatorInterface
  abstract def accept(type : ASR::Serializable.class, data : ASR::Any)
  abstract def accept(type : _, data : ASR::Any)
end

struct Athena::Serializer::Navigators::DeserializationNavigator
  include Athena::Serializer::Navigators::DeserializationNavigatorInterface

  @object_constructor : ASR::ObjectConstructorInterface = ASR::InstantiateObjectConstructor.new

  def initialize(@visitor : ASR::Visitors::DeserializationVisitorInterface, @context : ASR::DeserializationContext); end

  def accept(type : ASR::Serializable.class, data : ASR::Any)
    properties = type.deserialization_properties

    # Apply exclusion strategies if one is defined
    if strategy = @context.exclusion_strategy
      properties.reject! { |property| strategy.skip_property? property, @context }
    end

    object = @object_constructor.construct self, properties, data, type

    object.run_postdeserialize

    object
  end

  def accept(type : T, data : ASR::Any) forall T
    {% if T.has_method? :deserialize %}
      @visitor.visit type, data
    {% end %}
  end
end
