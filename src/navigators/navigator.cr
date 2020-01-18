require "./navigator_interface"

abstract class Athena::Serializer::Navigators::Navigator
  include Athena::Serializer::Navigators::NavigatorInterface

  def initialize(@visitor : ASR::Visitors::SerializationVisitorInterface, @context : ASR::SerializationContext); end
end
