@[ASR::ExclusionPolicy(:all)]
class PostDeserialize
  include ASR::Serializable

  def initialize; end

  getter first_name : String?
  getter last_name : String?

  @[ASR::Expose]
  getter name : String = "First Last"

  @[ASR::PostDeserialize]
  def split_name : Nil
    @first_name, @last_name = @name.split(' ')
  end
end
