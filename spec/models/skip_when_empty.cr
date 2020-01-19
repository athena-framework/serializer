class SkipWhenEmpty
  include ASR::Serializable

  @[ASR::SkipWhenEmpty]
  property value : String = "value"
end
