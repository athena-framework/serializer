require "./exclusion_strategy_interface"

struct Athena::Serializer::ExclusionStrategies::Groups
  include Athena::Serializer::ExclusionStrategies::ExclusionStrategyInterface

  @groups : Array(String)

  def initialize(@groups : Array(String)); end

  def self.new(*groups : String)
    new groups.to_a
  end

  # :inherit:
  def skip_property?(metadata : ASR::PropertyMetadataBase, context : ASR::Context) : Bool
    (metadata.groups & @groups).empty?
  end
end
