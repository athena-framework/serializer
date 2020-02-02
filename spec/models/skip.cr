class Skip
  include ASR::Serializable

  def initialize; end

  property one : String = "one"

  @[ASR::Skip]
  property two : String = "two"
end
