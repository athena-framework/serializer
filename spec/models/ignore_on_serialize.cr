class IgnoreOnSerialize
  include ASR::Serializable

  property name : String = "Fred"

  @[ASR::IgnoreOnSerialize]
  property password : String = "monkey"
end
