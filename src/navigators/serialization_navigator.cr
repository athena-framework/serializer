struct Athena::Serializer::Navigators::SerializationNavigator < Athena::Serializer::Navigators::Navigator
  def accept(data : ASR::Serializable) : Nil
    properties = data.serialization_properties

    # properties.run_preserialize

    # Apply exclusion strategies if one is defined
    if strategy = @context.exclusion_strategy
      properties.reject! { |property| strategy.skip_property? property, @context }
    end

    # Reject properties that shoud be skipped when empty
    # or properties that should be skipped when nil
    properties.reject! do |property|
      val = property.value
      skip_when_empty = property.skip_when_empty? && val.responds_to? :empty? && val.empty?
      skip_nil = !@context.emit_nil? && val.nil?

      skip_when_empty || skip_nil
    end

    # Process properties
    @visitor.visit properties

    # properties.run_postserializ
  end

  def accept(data : _) : Nil
    @visitor.visit data
  end
end
