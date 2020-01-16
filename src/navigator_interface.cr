module Athena::Serializabe::GraphNavigatorInterface
  abstract def init(visitor : ASR::VisitorInterface, context : ASR::Context)
  abstract def accept(data : _)
end
