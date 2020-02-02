class PreSerialize
  include ASR::Serializable

  def initialize; end

  getter name : String?
  getter age : Int32?

  @[ASR::PreSerialize]
  def set_name : Nil
    @name = "NAME"
  end

  @[ASR::PreSerialize]
  def set_age : Nil
    @age = 123
  end
end
