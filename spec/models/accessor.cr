class Accessor
  include ASR::Serializable

  @[ASR::Accessor(getter: get_foo)]
  property foo : String = "foo"

  private def get_foo : String
    @foo.upcase
  end
end
