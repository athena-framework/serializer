# Defines an abstraction that format specific types, such as `JSON::Any`, or `YAML::Any` must implement.
module Athena::Serializer::Any
  abstract def as_bool : Bool
  abstract def as_i : Int32
  abstract def as_i? : Int32?
  abstract def as_f : Float64
  abstract def as_f? : Float64?
  abstract def as_f32 : Float32
  abstract def as_f32? : Float32?
  abstract def as_i64 : Int64
  abstract def as_i64? : Int64?
  abstract def as_s : String
  abstract def as_s? : String?
  abstract def as_a
  abstract def as_a?
  abstract def as_h
  abstract def as_h?
end

struct JSON::Any
  include Athena::Serializer::Any
end

struct YAML::Any
  include Athena::Serializer::Any
end

# :nodoc:
def Union.new(visitor : ASR::Visitors::DeserializationVisitorInterface, data : ASR::Any?)
  {% begin %}
    # Try to parse the value as a primitive type first
    # as its faster than trying to parse a non-primitive type
    {% for type in T %}
      {% if type == Nil %}
        return nil if data.nil?
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
      return nil if data.nil?
    {% else %}
      begin
        return visitor.visit {{type}}, data
      rescue
        # Ignore
      end
    {% end %}
  {% end %}

  raise "Couldn't parse #{self} from '#{data}'."
end
