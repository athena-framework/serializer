require "./serializer_exception"

# Represents an error due to an invalid property.
#
# Exposes the property's name.
class Athena::Serializer::Exceptions::PropertyException < Athena::Serializer::Exceptions::SerializerException
  getter property_name : String

  def initialize(message : String, @property_name : String)
    super message
  end
end
