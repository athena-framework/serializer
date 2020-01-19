@[ASR::ExclusionPolicy(:none)]
class Exclude
  include ASR::Serializable

  property name : String = "Jim"

  @[ASR::Exclude]
  property password : String? = "monkey"
end
