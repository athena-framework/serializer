require "json"

struct Athena::Serializer::JSONVisitor < Athena::Serializer::SerializationVisitorInterface
  def initialize(io : IO) : Nil
    @builder = JSON::Builder.new io
  end

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
    accept data.serialization_properties
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
