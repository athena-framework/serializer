class GetterAccessor
  include ASR::Serializable

  def initialize; end

  @[ASR::Accessor(getter: get_foo)]
  @foo : String = "foo"

  private def get_foo : String
    @foo.upcase
  end
end

class SetterAccessor
  include ASR::Serializable

  @[ASR::Accessor(setter: set_foo)]
  getter foo : String

  private def set_foo(foo : String) : String
    foo.should eq "foo"
    @foo = "FOO"
  end
end
