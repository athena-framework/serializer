class Group
  include ASR::Serializable

  @[ASR::Groups("list", "details")]
  property id : Int64 = 1

  @[ASR::Groups("list")]
  property comment_summaries : Array(String) = ["Sentence 1.", "Sentence 2."]

  @[ASR::Groups("details")]
  property comments : Array(String) = ["Sentence 1.  Another sentence.", "Sentence 2.  Some other stuff."]

  property created_at : Time = Time.utc(2019, 1, 1)
end
