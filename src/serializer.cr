struct Athena::Serializer::Serializer
  include Athena::Serializer::SerializerInterface

  # def initialize(@navigators : Hash)

  def serialize(data : _, format : Format.class) : String
    unless data.is_a? Serializable
      return format.serialize data
    end

    format.serialize data.serialization_properties
  end

  private def visit(navigator, visitor, context, data, format)
  end
end
