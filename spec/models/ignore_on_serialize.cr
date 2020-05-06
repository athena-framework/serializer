class IgnoreOnSerialize
  include ASR::Serializable

  def initialize; end

  property name : String = "Fred"

  @[ASR::IgnoreOnSerialize]
  property password : String = "monkey"
end
