require "./context"
require "./navigator_interface"
require "./serialization_visitor_interface"
require "./json_serialization_visitor"
require "./serializer_interface"
require "./serializer"
require "./property_metadata"

alias ASR = Athena::Serializer

module Athena::Serializer
  module Format; end

  module Serializable
    abstract def serialization_properties : Array(ASR::Metadata)

    macro included
      {% verbatim do %}
        def serialization_properties : Array(ASR::Metadata)
          {% begin %}
            {% property_hash = {} of String => ASR::PropertyMetadata %}

            {% for ivar in @type.instance_vars %}
              {% property_hash[ivar.name.stringify] = %(ASR::PropertyMetadata(#{ivar.type}).new(name: #{ivar.name.stringify}, value: #{ivar.id})).id %}
            {% end %}

            {{property_hash.values}} of ASR::Metadata
          {% end %}
        end
      {% end %}
    end
  end
end

require "json"

module JSON
  include ASR::Format

  # Overload for Objects
  def self.serialize(properties : Array(ASR::Metadata)) : String
    String.build do |str|
      JSON.build(str) do |builder|
        ASR::JSONVisitor.new(builder).accept properties
      end
    end
  end

  # Overload for primitive types
  def self.serialize(obj : _) : String
    String.build do |str|
      JSON.build(str) do |builder|
        ASR::JSONVisitor.new(builder).visit obj
      end
    end
  end
end

class Bar
  include ASR::Serializable

  getter id, active

  def initialize(@id : String? = nil, @active = true); end
end

serializer = ASR::Serializer.new

obj = Bar.new "foo", false

puts serializer.serialize obj, JSON
