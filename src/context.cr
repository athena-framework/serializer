# Stores runtime data about the current action.
#
# Such as what serialization groups/version to use when serializing.
#
# NOTE: Cannot be used for more than one action.
abstract class Athena::Serializer::Context
  # The `ASR::ExclusionStrategies::ExclusionStrategyInterface` being used.
  getter exclusion_strategy : ASR::ExclusionStrategies::ExclusionStrategyInterface?

  @initialized : Bool = false

  # Returns the serialization groups, if any, currently set on `self`.
  getter groups : Array(String)? = nil

  # Returns the version, if any, currently set on `self`.
  getter version : SemanticVersion? = nil

  # Adds *strategy* to `self`.
  #
  # * `exclusion_strategy` is set to *strategy* if there previously was no strategy.
  # * `exclusion_strategy` is set to `ASR::ExclusionStrategies::Disjunct` if there was a `exclusion_strategy` already set.
  # * *strategy* is added to the `ASR::ExclusionStrategies::Disjunct` if there are multiple strategies.
  def add_exclusion_strategy(strategy : ASR::ExclusionStrategies::ExclusionStrategyInterface) : self
    current_strategy = @exclusion_strategy
    case current_strategy
    when Nil                                then @exclusion_strategy = strategy
    when ASR::ExclusionStrategies::Disjunct then current_strategy.members << strategy
    else
      @exclusion_strategy = ASR::ExclusionStrategies::Disjunct.new [current_strategy, strategy]
    end

    self
  end

  # :nodoc:
  def init : Nil
    raise Exception.new "This context was already initialized, and cannot be re-used." if @initialized

    if v = @version
      add_exclusion_strategy ASR::ExclusionStrategies::Version.new v
    end

    if g = @groups
      add_exclusion_strategy ASR::ExclusionStrategies::Groups.new g
    end

    @initialized = true
  end

  # Sets the group(s) to compare against properties' `ASRA::Groups` annotations.
  #
  # Adds a `ASR::ExclusionStrategies::Groups` automatically if set.
  def groups=(groups : Array(String)) : self
    raise ArgumentError.new "Groups cannot be empty" if groups.empty?

    @groups = groups

    self
  end

  # Sets the *version* to compare against properties' `ASRA::Since` and `ASRA::Until` annotations.
  #
  # Adds an `ASR::ExclusionStrategies::Version` automatically if set.
  def version=(version : String) : self
    @version = SemanticVersion.parse version

    self
  end
end
