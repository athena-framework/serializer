struct Athena::Serializer::Serializer
  include Athena::Serializer::SerializerInterface

  def serialize(data : _, format : ASR::Format, **named_args) : String
    String.build do |str|
      serialize data, format, str, **named_args
    end
  end

  def serialize(data : _, format : ASR::Format, io : IO, **named_args) : Nil
    format.serialization_visitor.new(io, **named_args).accept data.is_a?(ASR::Serializable) ? data.serialization_properties : data
  end

  # private def visit(navigator, visitor, context, data, format, io)
  # end
end
