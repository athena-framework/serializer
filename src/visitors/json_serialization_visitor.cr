require "json"
require "./serialization_visitor_interface"

class Athena::Serializer::Visitors::JSONVisitor < Athena::Serializer::Visitors::SerializationVisitorInterface
  property! navigator : ASR::Navigators::SerializationNavigator

  def initialize(io : IO, **named_args) : Nil
    @builder = JSON::Builder.new io
    if indent = named_args["indent"]?
      @builder.indent = indent
    end

    @builder.start_document
  end

  def finish
    @builder.end_document
  end

  # :inherit:
  def visit(properties : Array(Metadata)) : Nil
    @builder.object do
      properties.each do |prop|
        @builder.field(prop.name) do
          visit prop.value
        end
      end
    end
  end

  def visit(data : Nil) : Nil
    @builder.null
  end

  def visit(data : String) : Nil
    @builder.string data
  end

  def visit(data : Number) : Nil
    @builder.number data
  end

  def visit(data : Bool) : Nil
    @builder.bool data
  end

  def visit(data : Serializable) : Nil
    navigator.accept data
  end

  def visit(data : Hash) : Nil
    @builder.object do
      data.each do |key, value|
        @builder.field key.to_s do
          visit value
        end
      end
    end
  end

  def visit(data : Enumerable) : Nil
    @builder.array do
      data.each { |v| visit v }
    end
  end
end
