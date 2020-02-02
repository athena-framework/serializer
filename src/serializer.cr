struct Athena::Serializer::Serializer
  include Athena::Serializer::SerializerInterface

  def deserialize(type : _, input_data : String | IO, format : ASR::Format, context : ASR::DeserializationContext = ASR::DeserializationContext.new)
    # Initialize the context.  Currently just used to apply default exclusion strategies
    context.init

    visitor = format.deserialization_visitor.new
    navigator = ASR::Navigators::DeserializationNavigator.new visitor, context

    visitor.navigator = navigator

    data = visitor.prepare input_data

    navigator.accept type, data
  end

  def serialize(data : _, format : ASR::Format, context : ASR::SerializationContext = ASR::SerializationContext.new, **named_args) : String
    String.build do |str|
      serialize data, format, str, context, **named_args
    end
  end

  def serialize(data : _, format : ASR::Format, io : IO, context : ASR::SerializationContext = ASR::SerializationContext.new, **named_args) : Nil
    # Initialize the context.  Currently just used to apply default exclusion strategies
    context.init

    visitor = format.serialization_visitor.new(io, named_args)
    navigator = ASR::Navigators::SerializationNavigator.new visitor, context

    visitor.navigator = navigator

    visitor.prepare

    navigator.accept data

    visitor.finish
  end
end
