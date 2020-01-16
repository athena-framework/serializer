class Athena::Serializer::JSONVisitor
  include Athena::Serializabe::SerializationVisitorInterface

  def initialize(@builder : JSON::Builder); end

  def accept(properties : Array(Metadata)) : Nil
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
