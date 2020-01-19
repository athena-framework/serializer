class Default
  include ASR::Serializable

  property a : String = "A"
  property z : String = "Z"
  property two : String = "two"
  property one : String = "one"
  property a_a : Int32 = 123

  @[ASR::VirtualProperty]
  def get_val : String
    "VAL"
  end
end

@[ASR::AccessorOrder(:alphabetical)]
class Abc
  include ASR::Serializable

  property a : String = "A"
  property z : String = "Z"
  property one : String = "one"
  property a_a : Int32 = 123

  @[ASR::Name(serialize: "two")]
  property zzz : String = "two"

  @[ASR::VirtualProperty]
  def get_val : String
    "VAL"
  end
end

@[ASR::AccessorOrder(:custom, order: ["two", "z", "get_val", "a", "one", "a_a"])]
class Custom
  include ASR::Serializable

  property a : String = "A"
  property z : String = "Z"
  property two : String = "two"
  property one : String = "one"
  property a_a : Int32 = 123

  @[ASR::VirtualProperty]
  def get_val : String
    "VAL"
  end
end
