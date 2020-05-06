struct Athena::Serializer::Serializer
  include Athena::Serializer::SerializerInterface

  def deserialize(type : _, input_data : String | IO, format : ASR::Format | String, context : ASR::DeserializationContext = ASR::DeserializationContext.new)
    # Initialize the context.  Currently just used to apply default exclusion strategies
    context.init

    visitor = self.get_deserialization_visitor_class(format).new
    navigator = ASR::Navigators::DeserializationNavigator.new visitor, context

    visitor.navigator = navigator

    navigator.accept type, visitor.prepare input_data
  end

  def serialize(data : _, format : ASR::Format | String, context : ASR::SerializationContext = ASR::SerializationContext.new, **named_args) : String
    String.build do |str|
      serialize data, format, str, context, **named_args
    end
  end

  def serialize(data : _, format : ASR::Format | String, io : IO, context : ASR::SerializationContext = ASR::SerializationContext.new, **named_args) : Nil
    # Initialize the context.  Currently just used to apply default exclusion strategies
    context.init

    visitor = self.get_serialization_visitor(format).new(io, named_args)
    navigator = ASR::Navigators::SerializationNavigator.new visitor, context

    visitor.navigator = navigator

    visitor.prepare

    navigator.accept data

    visitor.finish
  end

  # Returns the `ASR::Visitors::DeserializationVisitorInterface.class` for the given *format*.
  #
  # Can be redefined in order to allow resolving custom formats.
  protected def get_deserialization_visitor_class(format : ASR::Format | String)
    if format.is_a? ASR::Format
      return format.deserialization_visitor
    end

    ASR::Format.parse(format).deserialization_visitor
  end

  # Returns the `ASR::Visitors::SerializationVisitorInterface.class` for the given *format*.
  #
  # Can be redefined in order to allow resolving custom formats.
  protected def get_serialization_visitor(format : ASR::Format | String)
    if format.is_a? ASR::Format
      return format.serialization_visitor
    end

    ASR::Format.parse(format).serialization_visitor
  end
end
