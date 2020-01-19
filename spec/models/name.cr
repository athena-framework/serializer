class SerializedName
  include ASR::Serializable

  @[ASR::Name(serialize: "myAddress")]
  property my_home_address : String = "123 Fake Street"

  @[ASR::Name(deserialize: "some_key", serialize: "a_value")]
  property value : String = "str"

  # ameba:disable Style/VariableNames
  property myZipCode : Int32 = 90210
end

class DeserializedName
  include ASR::Serializable

  @[ASR::Name(deserialize: "des")]
  property custom_name : Int32?

  property default_name : Bool?
end

class AliasName
  include ASR::Serializable

  @[ASR::Name(aliases: ["val", "value", "some_value"])]
  property some_value : String?
end
