module Athena::Serializer::Navigators::DeserializationNavigatorInterface
  abstract def accept(type : ASR::Serializable.class, data : ASR::Any)
  abstract def accept(type : T, data : ASR::Any) forall T
end

struct Athena::Serializer::Navigators::DeserializationNavigator
  include Athena::Serializer::Navigators::DeserializationNavigatorInterface

  @object_constructor : ASR::ObjectConstructorInterface = ASR::InstantiateObjectConstructor.new

  def initialize(@visitor : ASR::Visitors::DeserializationVisitorInterface, @context : ASR::DeserializationContext); end

  def accept(type : T.class, data : ASR::Any) forall T
    {% unless T.instance <= ASR::Serializable %}
      {% if T.has_method? :deserialize %}
        @visitor.visit type, data
      {% end %}
    {% else %}
      {% if ann = T.instance.annotation(ASR::Discriminator) %}
        if key = data[{{ann[:key]}}]?
          type = case key
            {% for k, t in ann[:map] %}
              when {{k}} then {{t}}
            {% end %}
          else
            raise "Unknown key"
          end
        else
          raise "Missing discriminator key"
        end
      {% end %}

      properties = type.deserialization_properties

      # Apply exclusion strategies if one is defined
      if strategy = @context.exclusion_strategy
        properties.reject! { |property| strategy.skip_property? property, @context }
      end

      object = @object_constructor.construct self, properties, data, type

      object.run_postdeserialize

      object
    {% end %}
  end
end
