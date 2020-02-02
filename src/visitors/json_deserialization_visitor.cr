require "json"
require "./serialization_visitor_interface"

class Athena::Serializer::Visitors::JSONDeserializationVisitor < Athena::Serializer::Visitors::DeserializationVisitorInterface
  property! navigator : Athena::Serializer::Navigators::NavigatorInterface

  def visit(type : ASR::Serializable.class, properties : Array(PropertyMetadataBase), data : JSON::Any)
    type.new self, properties, data
  end

  def visit(type : Int32.class, data : JSON::Any) : Int32
    data.as_i
  end

  def visit(type : Int32?.class, data : JSON::Any) : Int32?
    data.as_i?
  end

  def visit(type : Int64.class, data : JSON::Any) : Int64
    data.as_i64
  end

  def visit(type : Int64?.class, data : JSON::Any) : Int64?
    data.as_i64?
  end

  def visit(type : Float32?.class, data : JSON::Any) : Float32?
    data.as_f32?
  end

  def visit(type : Float32.class, data : JSON::Any) : Float32
    data.as_f32
  end

  def visit(type : Float64?.class, data : JSON::Any) : Float64?
    data.as_f?
  end

  def visit(type : Float64.class, data : JSON::Any) : Float64
    data.as_f
  end

  def visit(type : String?.class, data : JSON::Any) : String?
    data.as_s?
  end

  def visit(type : Nil.class, data : JSON::Any) : Nil
  end

  def visit(type : Array(T).class, data : JSON::Any) : Array forall T
    data.as_a.map do |item|
      visit T, item
    end
  end

  def prepare(input : IO | String) : JSON::Any
    JSON.parse input
  end
end
