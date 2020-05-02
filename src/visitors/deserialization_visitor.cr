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
    data.as_hash.each do |key, value|
      hash[visit(K, key)] = visit(V, value)
    end
    hash
  end

  def visit(type : Set(T).class, data : ASR::Any) : Set(T) forall T
    Set(T).new data.as_a.map { |item| visit T, item }
  end

  def visit(type : Set(T)?.class, data : ASR::Any) : Set(T)? forall T
    return unless arr = data.as_a?

    Set(T).new data.as_a.map { |item| visit T, item }
  end

  def visit(type : Tuple.class, data : ASR::Any)
    type.new self, data
  end

  def visit(type : Tuple?.class, data : ASR::Any)
    return unless data.as_a?

    type.new self, data
  end

  def visit(type : NamedTuple.class, data : ASR::Any)
    type.new self, data
  end

  def visit(type : NamedTuple?.class, data : ASR::Any)
    return unless data.as_hash?

    type.new self, data
  end

  def visit(type : Set(T)?.class, data : ASR::Any) : Set(T)? forall T
    return unless arr = data.as_a?

    Set(T).new arr.map { |item| visit T, item }
  end

  def visit(type : Array(T).class, data : ASR::Any) : Array(T) forall T
    data.as_a.map do |item|
      visit T, item
    end
  end

  def visit(type : Array(T)?.class, data : ASR::Any) : Array(T)? forall T
    return unless arr = data.as_a?

    arr.map do |item|
      visit T, item
    end
  end

  def visit(type : Union(T), data : ASR::Any) forall T
    type.new self, data
  end
end

# :nodoc:
def Tuple.new(visitor : ASR::Visitors::DeserializationVisitorInterface, data : ASR::Any)
  arr = data.as_a
  {% begin %}
    Tuple.new(
      {% for type, idx in T %}
        visitor.visit({{type}}, arr[{{idx}}]),
      {% end %}
    )
  {% end %}
end

# :nodoc:
def NamedTuple.new(visitor : ASR::Visitors::DeserializationVisitorInterface, data : ASR::Any)
  {% begin %}
    {% for key, type in T %}
      %var{key.id} = (val = data[{{key.id.stringify}}]?) ? visitor.visit({{type}}, val) : nil
    {% end %}

    {% for key, type in T %}
      if %var{key.id}.nil? && !{{type.nilable?}}
        raise "Missing required attribute: '{{key}}'"
      end
    {% end %}

    {
      {% for key, type in T %}
        {{key.id}}: (%var{key.id}).as({{type}}),
      {% end %}
    }
  {% end %}
end

# :nodoc:
def Union.new(visitor : ASR::Visitors::DeserializationVisitorInterface, data : ASR::Any?)
  {% begin %}

    # Try to parse the value as a primitive type first
    # as its faster than trying to parse a non-primitive type
    {% for type, index in T %}
      {% if type == Nil %}
        return nil if data.is_nil?
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
  {% end %}

  # Lastly, try to parse a non-primitive type if there are more than 1.
  {% for type in T %}
    {% if type == Nil %}
      return nil if data.is_nil?
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
