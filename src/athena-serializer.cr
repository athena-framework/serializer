require "semantic_version"
require "uuid"

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
    def serialization_visitor # : ASR::Visitors::SerializationVisitorInterface.class
      case self
      when .json? then ASR::Visitors::JSONSerializationVisitor
      when .yaml? then ASR::Visitors::YAMLSerializationVisitor
      else
        raise "unreachable"
      end
    end

    def deserialization_visitor # : ASR::Visitors::DeserializationVisitorInterface.class
      case self
      when .json? then ASR::Visitors::JSONDeserializationVisitor
      else
        raise "unreachable"
      end
    end
  end

  module Serializable
    abstract def serialization_properties : Array(ASR::PropertyMetadataBase)
    abstract def run_preserialize : Nil
    abstract def run_postserialize : Nil
    abstract def run_postdeserialize : Nil

    macro included
      {% verbatim do %}
        # :nodoc:
        def run_preserialize : Nil
          {% for method in @type.methods.select { |m| m.annotation(ASR::PreSerialize) } %}
            {{method.name}}
          {% end %}
        end

        # :nodoc:
        def run_postserialize : Nil
          {% for method in @type.methods.select { |m| m.annotation(ASR::PostSerialize) } %}
            {{method.name}}
          {% end %}
        end

        # :nodoc:
        def run_postdeserialize : Nil
          {% for method in @type.methods.select { |m| m.annotation(ASR::PostDeserialize) } %}
            {{method.name}}
          {% end %}
        end

        # :nodoc:
        def serialization_properties : Array(ASR::PropertyMetadataBase)
          {% begin %}
            # Construct the array of metadata from the properties on `self`.
            # Takes into consideration some annotations to control how/when a property should be serialized
            {%
              instance_vars = @type.instance_vars
                .reject { |ivar| ivar.annotation(ASR::Skip) }
                .reject { |ivar| (ann = @type.annotation(ASR::ExclusionPolicy)) && ann[0] == :all && !ivar.annotation(ASR::Expose) }  # ExclusionPolicy:ALL && ivar not Exposed
                .reject { |ivar| (ann = @type.annotation(ASR::ExclusionPolicy)) && ann[0] == :none && ivar.annotation(ASR::Exclude) } # ExclusionPolicy:NONE && ivar is Excluded
            %}

            {% property_hash = {} of Nil => Nil %}

            {% for ivar in instance_vars %}
              {% external_name = (ann = ivar.annotation(ASR::Name)) && (name = ann[:serialize]) ? name : ivar.name.stringify %}

              {% property_hash[external_name] = %(ASR::PropertyMetadata(#{ivar.type}, #{@type}).new(
                  name: #{ivar.name.stringify},
                  external_name: #{external_name},
                  value: #{(accessor = ivar.annotation(ASR::Accessor)) && accessor[:getter] != nil ? accessor[:getter].id : ivar.id},
                  skip_when_empty: #{!!ivar.annotation(ASR::SkipWhenEmpty)},
                  groups: #{(ann = ivar.annotation(ASR::Groups)) && !ann.args.empty? ? [ann.args.splat] : ["default"]},
                  since_version: #{(ann = ivar.annotation(ASR::Since)) && !ann[0].nil? ? "SemanticVersion.parse(#{ann[0]})".id : nil},
                  until_version: #{(ann = ivar.annotation(ASR::Until)) && !ann[0].nil? ? "SemanticVersion.parse(#{ann[0]})".id : nil},
                )).id %}
              {% end %}

            {% for m in @type.methods.select { |method| method.annotation(ASR::VirtualProperty) } %}
              {% method_name = m.name %}
              {% raise "VirtualProperty return type must be set for '#{@type.name}##{method_name}'." if m.return_type.is_a? Nop %}
              {% external_name = (ann = m.annotation(ASR::Name)) && (name = ann[:serialize]) ? name : m.name.stringify %}

              {% property_hash[external_name] = %(ASR::PropertyMetadata(#{m.return_type}, #{@type}).new(
                  name: #{m.name.stringify},
                  external_name: #{external_name},
                  value: #{m.name.id},
                  skip_when_empty: #{!!m.annotation(ASR::SkipWhenEmpty)},
                )).id %}
            {% end %}

            {% if (ann = @type.annotation(ASR::AccessorOrder)) && !ann[0].nil? %}
              {% if ann[0] == :alphabetical %}
                {% properties = property_hash.keys.sort.map { |key| property_hash[key] } %}
              {% elsif ann[0] == :custom && !ann[:order].nil? %}
                {% raise "Not all properties were defined in the custom order for '#{@type}'" unless property_hash.keys.all? { |prop| ann[:order].map(&.id.stringify).includes? prop } %}
                {% properties = ann[:order].map { |val| property_hash[val.id.stringify] || raise "Unknown instance variable: '#{val.id}'" } %}
              {% else %}
                {% raise "Invalid ASR::AccessorOrder value: '#{ann[0].id}'" %}
              {% end %}
            {% else %}
              {% properties = property_hash.values %}
            {% end %}

            {{properties}} of ASR::PropertyMetadataBase
          {% end %}
        end

        def self.deserialization_properties : Array(ASR::PropertyMetadataBase)
          {% verbatim do %}
            {% begin %}
              # Construct the array of metadata from the properties on `self`.
              # Takes into consideration some annotations to control how/when a property should be serialized
              {% instance_vars = @type.instance_vars
                   # ameba:disable Lint/ShadowingOuterLocalVar
                   .reject { |ivar| ivar.annotation(ASR::Skip) }
                   # ameba:disable Lint/ShadowingOuterLocalVar
                   .reject { |ivar| (ann = ivar.annotation(ASR::ReadOnly)); ann && !ivar.has_default_value? && !ivar.type.nilable? ? raise "#{@type}##{ivar.name} is read-only but is not nilable nor has a default value" : ann }
                   # ExclusionPolicy:ALL && ivar not Exposed
                   # ameba:disable Lint/ShadowingOuterLocalVar
                   .reject { |ivar| (ann = @type.annotation(ASR::ExclusionPolicy)) && ann[0] == :all && !ivar.annotation(ASR::Expose) }
                   # ExclusionPolicy:NONE && ivar is Excluded
                   # ameba:disable Lint/ShadowingOuterLocalVar
                   .reject { |ivar| (ann = @type.annotation(ASR::ExclusionPolicy)) && ann[0] == :none && ivar.annotation(ASR::Exclude) }
                   # ameba:disable Lint/ShadowingOuterLocalVar
                   .reject { |ivar| ivar.annotation(ASR::IgnoreOnDeserialize) } %}

              # ameba:disable Lint/ShadowingOuterLocalVar
              {{instance_vars.map do |ivar|
                  %(ASR::PropertyMetadata(#{ivar.type}?, #{@type}).new(
                    name: #{ivar.name.stringify},
                    external_name: #{(ann = ivar.annotation(ASR::Name)) && (name = ann[:deserialize]) ? name : ivar.name.stringify},
                    aliases: #{(ann = ivar.annotation(ASR::Name)) && (aliases = ann[:aliases]) ? aliases : "[] of String".id},
                    groups: #{(ann = ivar.annotation(ASR::Groups)) && !ann.args.empty? ? [ann.args.splat] : ["default"]},
                    since_version: #{(ann = ivar.annotation(ASR::Since)) && !ann[0].nil? ? "SemanticVersion.parse(#{ann[0]})".id : nil},
                    until_version: #{(ann = ivar.annotation(ASR::Until)) && !ann[0].nil? ? "SemanticVersion.parse(#{ann[0]})".id : nil},
                  )).id
                end}} of ASR::PropertyMetadataBase
            {% end %}
          {% end %}
        end

        def initialize(navigator : ASR::Navigators::DeserializationNavigator, properties : Array(ASR::PropertyMetadataBase), data : JSON::Any | YAML::Any)
          {% begin %}
            {% for ivar, idx in @type.instance_vars %}
              if (prop = properties.find { |p| p.name == {{ivar.name.stringify}} }) && ((val = data[prop.external_name]?) || ((key = prop.aliases.find { |a| data[a]? }) && (val = data[key]?)))
                value = navigator.accept {{ivar.type}}, val

                unless value.nil?
                  @{{ivar.id}} = value
                else
                  {% if !ivar.type.nilable? && !ivar.has_default_value? %}
                    raise Exception.new "Required property '{{ivar}}' cannot be nil"
                  {% end %}
                end
              else
                {% if !ivar.type.nilable? && !ivar.has_default_value? %}
                  raise Exception.new "Missing required attribute: '{{ivar}}'"
                {% end %}
              end
            {% end %}
          {% end %}
        end
      {% end %}
    end
  end
end

# class Parent
#   include ASR::Serializable

#   @[ASR::Name(aliases: ["n"])]
#   getter name : String?

#   @[ASR::Skip]
#   getter password : String? = nil

#   @[ASR::PostDeserialize]
#   private def post_d_parent
#     pp "DONE PARENT"
#   end
# end

# class User
#   include ASR::Serializable

#   @[ASR::Name(aliases: ["n"])]
#   getter name : String?
#   getter id : Int32
#   getter foo : Int32?

#   getter parent : Parent

#   @[ASR::PostDeserialize]
#   private def post_d_user
#     pp "DONE USER"
#   end
# end

# serializer = ASR::Serializer.new

# json = %({"n":"Jim","id":19,"parent":{"n":"Bob","password":"monkey123"}})

# pp serializer.deserialize User, json, :json
# pp serializer.deserialize Int32, "17", :json
# v = serializer.deserialize Int32 | Float32, "17.12", :json
# pp v
# pp typeof(v)
# pp serializer.deserialize String?, %("fsd"), :json
# pp serializer.deserialize String?, "null", :json
# v = serializer.deserialize Array(Int32), "[1,2,3]", :json
# pp v
# pp typeof(v)

# enum TestEnum
#   Zero
#   One
#   Two
#   Three
# end

# pp serializer.deserialize TestEnum?, "0", :json
