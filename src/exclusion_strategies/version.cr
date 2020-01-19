require "./exclusion_strategy_interface"

struct Athena::Serializer::ExclusionStrategies::Version
  include Athena::Serializer::ExclusionStrategies::ExclusionStrategyInterface

  getter version : SemanticVersion

  def initialize(@version : SemanticVersion); end

  # :inherit:
  def skip_property?(metadata : ASR::PropertyMetadataBase, context : ASR::Context) : Bool
    # Skip if *version* is not at least *since_version*.
    return true if (since_version = metadata.since_version) && @version < since_version

    # Skip if *version* is greater than or equal to than *until_version*.
    return true if (until_version = metadata.until_version) && @version >= until_version

    false
  end
end
