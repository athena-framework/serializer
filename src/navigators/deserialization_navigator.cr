module Athena::Serializer::Navigators::DeserializationNavigatorInterface
  abstract def initialize(@visitor : ASR::Visitors::DeserializationVisitorInterface, @context : ASR::DeserializationContext)

  abstract def accept(type : ASR::Serializable.class, data : JSON::Any) : ASR::Serializable
  abstract def accept(type : _, data : JSON::Any)
end

struct Athena::Serializer::Navigators::DeserializationNavigator
  include Athena::Serializer::Navigators::DeserializationNavigatorInterface

  def initialize(@visitor : ASR::Visitors::DeserializationVisitorInterface, @context : ASR::DeserializationContext); end

  def accept(type : ASR::Serializable.class, data : JSON::Any) : ASR::Serializable
    properties = type.deserialization_properties

    # Apply exclusion strategies if one is defined
    if strategy = @context.exclusion_strategy
      properties.reject! { |property| strategy.skip_property? property, @context }
    end

    result = @visitor.visit type, properties, data

    result.run_postdeserialize

    result
  end

  def accept(type : _, data : JSON::Any)
    @visitor.visit type, data
  end
end
