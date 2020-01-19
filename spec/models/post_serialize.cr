class PostSerialize
  include ASR::Serializable

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

  @[ASR::PostSerialize]
  def reset : Nil
    @age = nil
    @name = nil
  end
end
