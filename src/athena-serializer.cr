require "semantic_version"

require "./annotations"
require "./context"
require "./serializer_interface"
require "./serializer"
require "./property_metadata"
require "./serialization_context"

require "./exclusion_strategies/*"
require "./navigators/*"
require "./visitors/*"

alias ASR = Athena::Serializer

module Athena::Serializer
  enum Format
    JSON
    YAML

    # Returns the `ASR::SerializationVisitorInterface` to use with `self`.
    def serialization_visitor : ASR::Visitors::SerializationVisitorInterface.class
      case self
      when .json? then ASR::Visitors::JSONSerializationVisitor
      when .yaml? then ASR::Visitors::YAMLSerializationVisitor
      else
        raise "unreachable"
      end
    end
  end

  enum ExclusionPolicy
    All
    None
  end

  module Serializable
    abstract def serialization_properties : Array(ASR::Metadata)

    macro included
      {% verbatim do %}
        def serialization_properties : Array(ASR::Metadata) 
          {% begin %}
            # Construct the array of metadata from the properties on `self`.
            # Takes into consideration some annotations to control how/when a property should be serialized
            {%
              ivars = @type.instance_vars
                .reject { |ivar| ivar.annotation(ASR::Annotations::Skip) }
                .reject { |ivar| (ann = @type.annotation(ASR::Annotations::ExclusionPolicy)) && ann[0] == :all && !ivar.annotation(ASR::Annotations::Expose) }  # ExclusionPolicy:ALL && ivar not Exposed
                .reject { |ivar| (ann = @type.annotation(ASR::Annotations::ExclusionPolicy)) && ann[0] == :none && ivar.annotation(ASR::Annotations::Exclude) } # ExclusionPolicy:NONE && ivar is Excluded
            %}

            {% property_hash = {} of Nil => Nil %}

            {% for ivar in ivars %}
              {% external_name = (ann = ivar.annotation(ASR::Annotations::Name)) && (name = ann[:serialize]) ? name : ivar.name.stringify %}

              {% property_hash[external_name] = %(ASR::PropertyMetadata(
                  #{ivar.type},
                  #{@type},
                )
                .new(
                  name: #{ivar.name.stringify},
                  external_name: #{external_name},
                  value: #{(accessor = ivar.annotation(ASR::Annotations::Accessor)) && accessor[:getter] != nil ? accessor[:getter].id : ivar.id},
                  skip_when_empty: #{!!ivar.annotation(ASR::Annotations::SkipWhenEmpty)},
                  groups: #{(ann = ivar.annotation(ASR::Annotations::Groups)) && !ann.args.empty? ? [ann.args.splat] : ["default"]},
                  since_version: #{(ann = ivar.annotation(ASR::Annotations::Since)) && !ann[0].nil? ? "SemanticVersion.parse(#{ann[0]})".id : nil},
                  until_version: #{(ann = ivar.annotation(ASR::Annotations::Until)) && !ann[0].nil? ? "SemanticVersion.parse(#{ann[0]})".id : nil},
                )).id %}
              {% end %}

            {% for m in @type.methods.select { |method| method.annotation(ASR::Annotations::VirtualProperty) } %}
              {% method_name = m.name %}
              {% raise "VirtualProperty return type must be set for '#{@type.name}##{method_name}'." if m.return_type.is_a? Nop %}
              {% external_name = (ann = m.annotation(ASR::Annotations::Name)) && (name = ann[:serialize]) ? name : m.name.stringify %}

              {% property_hash[external_name] = %(ASR::PropertyMetadata(
                      #{m.return_type},
                      #{@type},
                    )
                    .new(
                      name: #{m.name.stringify},
                      external_name: #{external_name},
                      value: #{m.name.id},
                      skip_when_empty: #{!!m.annotation(ASR::Annotations::SkipWhenEmpty)},
                    )).id %}
            {% end %}

            {% if (ann = @type.annotation(ASR::Annotations::AccessorOrder)) && !ann[0].nil? %}
              {% if ann[0] == :alphabetical %}
                {% properties = property_hash.keys.sort.map { |key| property_hash[key] } %}
              {% elsif ann[0] == :custom && !ann[:order].nil? %}
                {% raise "Not all properties were defined in the custom order for '#{@type}'" unless property_hash.keys.all? { |prop| ann[:order].map(&.id.stringify).includes? prop } %}
                {% properties = ann[:order].map { |val| property_hash[val.id.stringify] || raise "Unknown instance variable: '#{val.id}'" } %}
              {% else %}
                {% raise "Invalid ASR::Annotations::AccessorOrder value: '#{ann[0].id}'" %}
              {% end %}
            {% else %}
              {% properties = property_hash.values %}
            {% end %}

            {{properties}} of ASR::Metadata
          {% end %}
        end
      {% end %}
    end
  end
end
