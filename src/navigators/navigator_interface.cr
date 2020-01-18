module Athena::Serializer::Navigators::NavigatorInterface
  abstract def accept(data : ASR::Serializable) : Nil
  abstract def accept(data : _) : Nil
end
