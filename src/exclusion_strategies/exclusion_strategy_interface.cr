# Represents a specific exclusion strategy.
#
# Custom logic can be implemented by defining a type with this interface.
# It can then be used via `ASR::Context#add_exclusion_strategy`.
#
# ## Example
#
# ```
# struct OddNumberExclusionStrategy
#   include Athena::Serializer::ExclusionStrategies::ExclusionStrategyInterface
#
#   # :inherit:
#   #
#   # Skips serializing odd numbered values
#   def skip_property?(metadata : ASR::PropertyMetadataBase, context : ASR::Context) : Bool
#     # Don't skip if the value is nil
#     return false unless value = (metadata.value)
#
#     # Only skip on serialization, if the value is an number, and if it's odd.
#     context.is_a?(ASR::SerializationContext) && value.is_a?(Number) && value.odd?
#   end
# end
#
# serialization_context = ASR::SerializationContext.new
# serialization_context.add_exclusion_strategy OddNumberExclusionStrategy.new
#
# deserialization_context = ASR::DeserializationContext.new
# deserialization_context.add_exclusion_strategy OddNumberExclusionStrategy.new
#
# record Values, one : Int32 = 1, two : Int32 = 2, three : Int32 = 3 do
#   include ASR::Serializable
# end
#
# ASR.serializer.serialize Values.new, :json, serialization_context                                 # => {"two":2}
# ASR.serializer.deserialize Values, %({"one":4,"two":5,"three":6}), :json, deserialization_context # => Values(@one=4, @three=6, @two=5)
# ```
module Athena::Serializer::ExclusionStrategies::ExclusionStrategyInterface
  # Returns `true` if a property should _NOT_ be (de)serialized.
  abstract def skip_property?(metadata : ASR::PropertyMetadataBase, context : ASR::Context) : Bool
end
