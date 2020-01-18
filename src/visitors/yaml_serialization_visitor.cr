require "yaml"

class Athena::Serializer::Visitors::YAMLSerializationVisitor < Athena::Serializer::Visitors::SerializationVisitorInterface
  property! navigator : ASR::Navigators::SerializationNavigator

  def initialize(io : IO, **named_args) : Nil
    @builder = YAML::Builder.new io
  end

  def prepare : Nil
    @builder.start_stream
    @builder.start_document
  end

  def finish : Nil
    @builder.end_document
    @builder.end_stream
  end

  # :inherit:
  def visit(properties : Array(Metadata)) : Nil
    @builder.mapping do
      properties.each do |prop|
        @builder.scalar prop.external_name
        visit prop.value
      end
    end
  end

  def visit(data : Nil) : Nil
    @builder.scalar data
  end

  def visit(data : String) : Nil
    @builder.scalar data
  end

  def visit(data : Number) : Nil
    @builder.scalar data
  end

  def visit(data : Bool) : Nil
    @builder.scalar data
  end

  def visit(data : Serializable) : Nil
    navigator.accept data
  end

  def visit(data : Hash) : Nil
    @builder.mapping do
      data.each do |key, value|
        @builder.scalar key
        @builder.scalar visit value
      end
    end
  end

  def visit(data : Enumerable) : Nil
    @builder.sequence do
      data.each { |v| visit v }
    end
  end
end
