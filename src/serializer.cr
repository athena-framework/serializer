struct Athena::Serializer::Serializer
  include Athena::Serializer::SerializerInterface

  def serialize(data : _, format : ASR::Format, context : ASR::SerializationContext = ASR::SerializationContext.new, **named_args) : String
    String.build do |str|
      serialize data, format, str, context, **named_args
    end
  end

  def serialize(data : _, format : ASR::Format, io : IO, context : ASR::SerializationContext = ASR::SerializationContext.new, **named_args) : Nil
    # Initialize the context.  Currently just used to apply default exclusion strategies
    context.init

    visitor = format.serialization_visitor.new(io, **named_args)
    navigator = ASR::Navigators::SerializationNavigator.new visitor, context

    visitor.navigator = navigator
    navigator.init # context

    navigator.accept data

    visitor.finish
  end
end
