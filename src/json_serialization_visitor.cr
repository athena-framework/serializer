require "json"

struct Athena::Serializer::JSONVisitor < Athena::Serializer::SerializationVisitorInterface
  def initialize(io : IO, **named_args) : Nil
    @builder = JSON::Builder.new io
    if indent = named_args["indent"]?
      @builder.indent = indent
    end
  end

  # :inherit:
  def accept(properties : Array(Metadata)) : Nil
    @builder.document do
      @builder.object do
        properties.each do |prop|
          @builder.field(prop.name) do
            visit prop.value
          end
        end
      end
    end
  end

  # :inherit:
  def accept(data : _) : Nil
    @builder.document do
      visit data
    end
  end

  protected def visit(data : Nil) : Nil
    @builder.null
  end

  protected def visit(data : String) : Nil
    @builder.string data
  end

  protected def visit(data : Number) : Nil
    @builder.number data
  end

  protected def visit(data : Bool) : Nil
    @builder.bool data
  end

  protected def visit(data : Serializable) : Nil
    @builder.object do
      data.serialization_properties.each do |prop|
        @builder.field(prop.name) do
          visit prop.value
        end
      end
    end
  end

  protected def visit(data : Hash) : Nil
    @builder.object do
      data.each do |key, value|
        @builder.field key.to_s do
          visit value
        end
      end
    end
  end

  protected def visit(data : Enumerable) : Nil
    @builder.array do
      data.each { |v| visit v }
    end
  end
end
