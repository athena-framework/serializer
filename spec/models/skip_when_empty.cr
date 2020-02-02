class SkipWhenEmpty
  include ASR::Serializable

  def initialize; end

  @[ASR::SkipWhenEmpty]
  property value : String = "value"
end
