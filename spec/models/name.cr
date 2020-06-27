class SerializedName
  include ASR::Serializable

  def initialize; end

  @[ASRA::Name(serialize: "myAddress")]
  property my_home_address : String = "123 Fake Street"

  @[ASRA::Name(deserialize: "some_key", serialize: "a_value")]
  property value : String = "str"

  # ameba:disable Style/VariableNames
  property myZipCode : Int32 = 90210
end

@[ASRA::Name(strategy: :camelcase)]
class SerializedNameCamelcaseStrategy
  include ASR::Serializable

  def initialize; end

  # Is overridable
  @[ASRA::Name(serialize: "myAdd_ress")]
  property my_home_address : String = "123 Fake Street"

  # ameba:disable Style/VariableNames
  property two_wOrds : String = "two words"

  # ameba:disable Style/VariableNames
  property myZipCode : Int32 = 90210
end

@[ASRA::Name(strategy: :underscore)]
class SerializedNameUnderscoreStrategy
  include ASR::Serializable

  def initialize; end

  # Is overridable
  @[ASRA::Name(serialize: "myAdd_ress")]
  property my_home_address : String = "123 Fake Street"

  # ameba:disable Style/VariableNames
  property two_wOrds : String = "two words"

  # ameba:disable Style/VariableNames
  property myZipCode : Int32 = 90210
end

@[ASRA::Name(strategy: :identical)]
class SerializedNameIdenticalStrategy
  include ASR::Serializable

  def initialize; end

  # Is overridable
  @[ASRA::Name(serialize: "myAdd_ress")]
  property my_home_address : String = "123 Fake Street"

  # ameba:disable Style/VariableNames
  property two_wOrds : String = "two words"

  # ameba:disable Style/VariableNames
  property myZipCode : Int32 = 90210
end

class DeserializedName
  include ASR::Serializable

  def initialize; end

  @[ASRA::Name(deserialize: "des")]
  property custom_name : Int32?

  property default_name : Bool?
end

class AliasName
  include ASR::Serializable

  def initialize; end

  @[ASRA::Name(aliases: ["val", "value", "some_value"])]
  property some_value : String?
end
