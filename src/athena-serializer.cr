require "./context"
require "./serialization_visitor_interface"
require "./json_serialization_visitor"
require "./serializer_interface"
require "./serializer"
require "./property_metadata"

alias ASR = Athena::Serializer

module Athena::Serializer
  enum Format
    JSON

    # Returns the `ASR::SerializationVisitorInterface` to use with `self`.
    def serialization_visitor : ASR::SerializationVisitorInterface.class
      case self
      when .json? then ASR::JSONVisitor
      else
        raise "unreachable"
      end
    end
  end

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
