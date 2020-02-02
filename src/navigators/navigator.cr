require "./navigator_interface"

abstract struct Athena::Serializer::Navigators::Navigator
  include Athena::Serializer::Navigators::NavigatorInterface
end
