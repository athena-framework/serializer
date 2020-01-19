class VirtualProperty
  include ASR::Serializable

  property foo : String = "foo"

  @[ASR::VirtualProperty]
  def get_val : String
    "VAL"
  end
end
