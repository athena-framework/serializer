require "./navigator"

struct Athena::Serializer::Navigators::DeserializationNavigator < Athena::Serializer::Navigators::Navigator
  def initialize(@visitor : ASR::Visitors::DeserializationVisitorInterface, @context : ASR::DeserializationContext); end

  def accept(type : ASR::Serializable.class, data : JSON::Any)
    properties = type.deserialization_properties

    # Apply exclusion strategies if one is defined
    if strategy = @context.exclusion_strategy
      properties.reject! { |property| strategy.skip_property? property, @context }
    end

    @visitor.visit type, properties, data
  end

  def accept(type : _, data : JSON::Any)
    @visitor.visit type, data
  end
end
