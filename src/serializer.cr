struct Athena::Serializer::Serializer
  include Athena::Serializer::SerializerInterface

  @visitors : Hash(ASR::Format, ASR::SerializationVisitorInterface.class)

  def initialize(*, visitors : Array(ASR::SerializationVisitorInterface.class)? = nil)
    @visitors = Hash(ASR::Format, ASR::SerializationVisitorInterface.class).new

    @visitors[ASR::Format::JSON] = ASR::JSONVisitor

    # visitor_arr.each do |visitor|
    #   @visitors[visitor.format] = visitor
    # end
  end

  def serialize(data : _, format : ASR::Format) : String
    String.build do |str|
      serialize data, format, str
    end
  end

  def serialize(data : _, format : ASR::Format, io : IO) : Nil
    @visitors[format].new(io).accept data.is_a?(ASR::Serializable) ? data.serialization_properties : data
  end

  # private def visit(navigator, visitor, context, data, format, io)
  # end
end
