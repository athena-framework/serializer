class IgnoreOnDeserialize
  include ASR::Serializable

  property name : String = "Fred"

  @[ASR::IgnoreOnDeserialize]
  property password : String = "monkey"
end
