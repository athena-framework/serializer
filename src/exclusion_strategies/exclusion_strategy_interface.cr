# Represents a specific exclusion strategy.
#
# Custom logic can be implemented by defining a type with this interface.
# It can then be used via `ASR::Context#add_exclusion_strategy`.
#
# ## Example
#
# ```
# ```
module Athena::Serializer::ExclusionStrategies::ExclusionStrategyInterface
  # Returns `true` if a property should _NOT_ be (de)serialized.
  abstract def skip_property?(metadata : ASR::PropertyMetadataBase, context : ASR::Context) : Bool
end
