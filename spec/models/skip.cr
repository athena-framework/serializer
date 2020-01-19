class Skip
  include ASR::Serializable

  property one : String = "one"

  @[ASR::Skip]
  property two : String = "two"
end
