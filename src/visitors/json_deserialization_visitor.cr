require "json"
require "./serialization_visitor_interface"

class Athena::Serializer::Visitors::JSONDeserializationVisitor
  include Athena::Serializer::Visitors::DeserializationVisitorInterface

  property! navigator : Athena::Serializer::Navigators::DeserializationNavigatorInterface

  def prepare(input : IO | String) : JSON::Any
    JSON.parse input
  end

  # Use a macro to build out primitive types
  {% begin %}
    {%
      primitives = {
        Bool    => ".as_bool",
        Float32 => ".as_f32",
        Float64 => ".as_f",
        Int32   => ".as_i",
        Int64   => ".as_i64",
        String  => ".as_s",
      }
    %}

    {% for type, method in primitives %}
      def visit(type : {{type}}.class, data : JSON::Any) : {{type}}
        data{{method.id}}
      end
    {% end %}
  {% end %}

  def visit(type : Enum.class, data : JSON::Any) : Enum
    if val = data.as_i64?
      type.from_value val
    elsif val = data.as_s?
      type.parse val
    else
      raise "Couldn't parse #{type} from '#{data}'."
    end
  end

  def visit(type : ASR::Serializable.class, properties : Array(PropertyMetadataBase), data : JSON::Any)
    type.new navigator.as(ASR::Navigators::DeserializationNavigator), properties, data
  end

  def visit(type : Nil.class, data : JSON::Any) : Nil
  end

  def visit(type : Enumerable(T).class, data : JSON::Any) : Array forall T
    data.as_a.map do |item|
      visit T, item
    end
  end

  def visit(type : Enumerable(T)?.class, data : JSON::Any) forall T
    return nil unless arr = data.as_a?

    arr.map do |item|
      visit T, item
    end
  end

  def visit(type : Union(T), data : JSON::Any) forall T
    type.new self, data
  end
end

# :nodoc:
def Union.new(visitor : ASR::Visitors::DeserializationVisitorInterface, data : JSON::Any)
  {% begin %}
    {% non_primitives = [] of Nil %}

    # Try to parse the value as a primitive type first
    # as its faster than trying to parse a non-primitive type
    {% for type, index in T %}
      {% if type == Nil %}
        return nil if data.raw.is_a? Nil
      {% elsif type < Int %}
        if value = data.as_i?
          return {{type}}.new! value
        end
      {% elsif type < Float %}
        if value = data.as_f?
          return {{type}}.new! value
        end
      {% elsif type == Bool || type == String %}
        value = data.raw.as? {{type}}
        return value unless value.nil?
      {% end %}
    {% end %}

    # Parse the type directly if there is only 1 non-primitive type
    {% if non_primitives.size == 1 %}
      return visitor.visit {{non_primitives[0]}}, data
    {% end %}
  {% end %}

  # Lastly, try to parse a non-primitive type if there are more than 1.
  {% for type in T %}
    {% if type == Nil %}
      return nil if data.raw.is_a? Nil
    {% else %}
      begin
        return visitor.visit {{type}}, data
      rescue ex
        # Ignore
      end
    {% end %}
  {% end %}

  raise "Couldn't parse #{self} from '#{data}'."
end
