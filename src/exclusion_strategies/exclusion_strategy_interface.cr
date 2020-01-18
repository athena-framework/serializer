module Athena::Serializer::ExclusionStrategies::ExclusionStrategyInterface
  # Returns `true` if a property should _NOT_ be serialized/deserialized.
  abstract def skip_property?(metadata : ASR::PropertyMetadata, context : ASR::Context) : Bool
end
