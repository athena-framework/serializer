@[ASR::ExclusionPolicy(:none)]
class Exclude
  include ASR::Serializable

  def initialize; end

  property name : String = "Jim"

  @[ASR::Exclude]
  property password : String? = "monkey"
end