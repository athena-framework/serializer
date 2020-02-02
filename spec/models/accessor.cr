class Accessor
  include ASR::Serializable

  def initialize; end

  @[ASR::Accessor(getter: get_foo)]
  property foo : String = "foo"

  private def get_foo : String
    @foo.upcase
  end
end
