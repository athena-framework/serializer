require "./deserialization_visitor_interface"

# Implement deserialization logic based on `ASR::Any` common to all formats.
abstract class Athena::Serializer::Visitors::DeserializationVisitor
  include Athena::Serializer::Visitors::DeserializationVisitorInterface

  property! navigator : Athena::Serializer::Navigators::DeserializationNavigatorInterface

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
      def visit(type : {{type}}.class, data : ASR::Any) : {{type}}
        data{{method.id}}
      end
    {% end %}
  {% end %}

  def visit(type : Number.class, data : String) : Number
    type.new data
  end

  def visit(type : Enum.class, data : ASR::Any) : Enum
    if val = data.as_i64?
      type.from_value val
    elsif val = data.as_s?
      type.parse val
    else
      raise "Couldn't parse #{type} from '#{data}'."
    end
  end

  def visit(type : Nil.class, data : ASR::Any) : Nil
  end

  def visit(type : Hash(K, V).class, data : ASR::Any) : Hash forall K, V
    hash = Hash(K, V).new
    data.as_h.each do |key, value|
      hash[visit(K, key)] = visit V, value
    end
    hash
  end

  def visit(type : Enumerable(T).class, data : ASR::Any) : Array forall T
    data.as_a.map do |item|
      visit T, item
    end
  end

  def visit(type : Enumerable(T)?.class, data : ASR::Any) forall T
    return unless arr = data.as_a?

    arr.map do |item|
      visit T, item
    end
  end

  def visit(type : Union(T), data : ASR::Any) forall T
    type.new self, data
  end
end
