module JsonShape
  class Kind
    attr :name
    attr :params

    def initialize(kind)
      if kind.is_a?(Array)
        @name, @params = kind
      else
        @name = kind
        @params = {}
      end
    end

    def inspect
      [name, params].inspect
    end

    def method_missing(name, *args)
      name = name.to_s
      if /\!$/ =~ name
        name.chop!
        @params[name].tap{|x| raise "#{name} is not defined" unless x}
      elsif /\?$/ =~ name
        name.chop!
        @params.has_key?(name)
      else
        @params[name]
      end
    end

    def is_definition?(name)
      self.name == name
    end
  end

  class Failure < ArgumentError
    def initialize( message, object, kind, path )
      @message, @object, @kind, @path = message, object, kind, path
    end

    def to_s
      "#{ @message }: #{ @object.inspect } found when expecting #{ @kind.inspect }, at #{ @path.join('/') }"
    end

    def message
      to_s
    end
  end

  def self.schema_check( object, kind, schema = {}, path = [])
    kind = Kind.new(kind)

    failure = lambda{|message| raise Failure.new(message, object, kind, path) }

    case
    # simple values
    when kind.is_definition?("string")
      failure["not a string"] unless object.is_a? String
      if kind.matches? and object !~ Regexp.new(kind.matches)
        failure["does not match /#{kind.matches}/"]
      end
    when kind.is_definition?("number")
      failure["not a number"] unless object.is_a? Numeric
      failure["less than min #{kind.min}"] if kind.min? and object < kind.min
      failure["greater than max #{kind.max}"] if kind.max? and object > kind.max
    when kind.is_definition?("boolean")
      failure["not a boolean"] unless object == true || object == false
    when kind.is_definition?("null")
      failure["not null"] unless object == nil
    when kind.is_definition?("undefined")
      object == :undefined or failure["is not undefined"]

    # complex values
    when kind.is_definition?("array")
      failure[ "not an array" ] unless object.is_a? Array
      if kind.contents?
        object.each_with_index do |entry, i|
          schema_check( entry, kind.contents, schema, path + [i] )
        end
      end
      if kind.length?
        schema_check( object.length, kind.length, schema, path + ["_length_"] )
      end

    when kind.is_definition?("object")
      object.is_a?(Hash) or failure["not an object"]
      if kind.members?
        kind.members.each do |name, spec|
          val = object.has_key?(name) ? object[name] : :undefined
          next if val == :undefined and kind.allow_missing
          schema_check( val, spec, schema, path + [name] )
        end
        if kind.allow_extra != true
          extras = object.keys - kind.members.keys
          failure[ "#{extras.inspect} are not valid members" ] if extras != []
        end
      end

    # obvious extensions
    when kind.is_definition?("anything")
      object != :undefined or failure[ "is not defined" ]

    when kind.is_definition?("literal")
      object == kind.params or failure[ "doesn't match" ]

    when kind.is_definition?("integer")
      schema_check( object, ["number", kind.params], schema, path)
      object.is_a?(Integer) or failure[ "is not an integer" ]

    when kind.is_definition?("enum")
      kind.values!.find_index do |value|
        value == object
      end or failure["does not match any choice"]

    when kind.is_definition?("tuple")
      schema_check( object, "array", schema, path )
      failure["tuple is the wrong size"] if object.length > kind.elements!.length
      undefineds = [:undefined] * (kind.elements!.length - object.length)
      kind.elements!.zip(object + undefineds).each_with_index do |pair, i|
        spec, value = pair
        schema_check( value, spec, schema, path + [i] )
      end

    when kind.is_definition?("dictionary")
      schema_check( object, "object", schema, path )

      object.each do |key, value|
        if kind.contents?
          schema_check( value, kind.contents, schema, path + [key] )
        end
        if kind.keys?
          schema_check( key, kind.keys, schema, path + [key] )
        end
      end

    # set theory
    when kind.is_definition?("either")
      kind.choices!.find_index do |choice|
        begin
          schema_check( object, choice, schema, path )
          true
        rescue Failure
          false
        end
      end or failure["does not match any choice"]

    when kind.is_definition?("optional")
      object == :undefined or schema_check( object, kind.params, schema, path )

    when kind.is_definition?("nullable")
      object == nil or schema_check( object, kind.params, schema, path )

    when kind.is_definition?("restrict")
      if kind.require?
        kind.require.each do |requirement|
          schema_check( object, requirement, schema, path )
        end
      end
      if kind.reject?
        kind.reject.each do |rule|
          begin
            schema_check( object, rule, schema, path )
            false
          rescue Failure
            true
          end or failure["violates #{rule.inspect}"]
        end
      end

    # custom types
    when schema[kind.name]
      schema_check( object, schema[kind.name], schema, path )
    else
      raise "Invalid definition #{kind.inspect}"
    end
  end
end

if __FILE__ == $0
  require 'rubygems'
  require 'json'

  schema = JSON.parse( File.read( ARGV[0] ) )

  type = ARGV[1]

  if ARGV[2]
    stream = File.open(ARGV[2])
  else
    stream = STDIN
  end

  data = JSON.parse( stream.read )

  JsonShape.schema_check( data, type, schema )
end
