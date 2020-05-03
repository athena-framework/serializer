require "./deserialization_visitor_interface"

# Implement deserialization logic based on `ASR::Any` common to all formats.
abstract class Athena::Serializer::Visitors::DeserializationVisitor
  include Athena::Serializer::Visitors::DeserializationVisitorInterface

  property! navigator : Athena::Serializer::Navigators::DeserializationNavigatorInterface

  # def visit(type : String.class, data : String) : String
  #   data
  # end

  # def visit(type : Number.class, data : String)
  #   type.new data
  # end

  def visit(type : Nil.class, data : ASR::Any) : Nil
  end

  macro finished
    def visit(type : _, data : ASR::Any)
      type.deserialize self, data
    end
  end
end

# Use a macro to build out primitive types
{% begin %}
  {%
    primitives = {
      Bool    => ".as_bool",
      Float32 => ".as_f32",
      Float64 => ".as_f",
      Int8    => ".as_i.to_i8",
      Int16   => ".as_i.to_i16",
      Int32   => ".as_i",
      Int64   => ".as_i64",
      UInt8   => ".as_i64.to_u8",
      UInt16  => ".as_i64.to_u16",
      UInt32  => ".as_i64.to_u32",
      UInt64  => ".as_i64.to_u64",
      String  => ".as_s",
    }
  %}

  {% for type, method in primitives %}
    def {{type}}.deserialize(visitor : ASR::Visitors::DeserializationVisitorInterface, data : ASR::Any)
      data{{method.id}}
    end
  {% end %}
{% end %}

# :nodoc:
def String.deserialize(visitor : ASR::Visitors::DeserializationVisitorInterface, data : ASR::Any)
  data.as_s
end

def Array.deserialize(visitor : ASR::Visitors::DeserializationVisitorInterface, data : ASR::Any)
  ary = new
  data.as_a.each do |element|
    if T.responds_to? :deserialize
      ary << visitor.navigator.accept(T, element)
    end
  end
  ary
end

# :nodoc:
def Tuple.deserialize(visitor : ASR::Visitors::DeserializationVisitorInterface, data : ASR::Any)
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
def NamedTuple.deserialize(visitor : ASR::Visitors::DeserializationVisitorInterface, data : ASR::Any)
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
def Union.deserialize(visitor : ASR::Visitors::DeserializationVisitorInterface, data : ASR::Any)
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
