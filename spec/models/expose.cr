@[ASR::ExclusionPolicy(:all)]
class Expose
  include ASR::Serializable

  @[ASR::Expose]
  property name : String = "Jim"

  property password : String? = "monkey"
end
