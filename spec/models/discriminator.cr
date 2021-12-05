@[ASRA::Discriminator(key: "type", map: {"point" => Point, "circle" => Circle})]
abstract class Shape
  include ASR::Serializable

  property type : String
end

class Point < Shape
  property x : Int32
  property y : Int32
end

class Circle < Shape
  property x : Int32
  property y : Int32
  property radius : Int32
end

@[ASRA::Discriminator(key: "type", map: {"triangle" => Triangle}, default: GenericPolygon)]
abstract class Polygon
  include ASR::Serializable

  property type : String
end

class Triangle < Polygon
  property p1 : Point
  property p2 : Point
  property p3 : Point
end

class GenericPolygon < Polygon
  property vertices : Array(Point)
end
