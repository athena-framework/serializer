class VirtualProperty
  include ASR::Serializable

  def initialize; end

  property foo : String = "foo"

  @[ASR::VirtualProperty]
  def get_val : String
    "VAL"
  end
end
