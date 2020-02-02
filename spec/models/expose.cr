@[ASR::ExclusionPolicy(:all)]
class Expose
  include ASR::Serializable

  def initialize; end

  @[ASR::Expose]
  property name : String = "Jim"

  property password : String? = "monkey"
end
