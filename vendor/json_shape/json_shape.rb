module JsonShape
  class IsDefinition
    attr :name, :params

    def self.[](name)
      self.new(name)
    end
    def initialize(name)
      @name = name
    end

    def ===(val)
      return true if val.name == @name
    end

  end

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
  end

  class Failure < ArgumentError
    def initialize( message, object, kind, path )
      @message, @object, @kind, @path = message, object, kind, path
    end

    def to_s
      "#{ @message }: #{ @object.inspect } found when expecting #{ @kind.inspect }, at #{ @path.inspect }"
    end

    def message
      to_s
    end
  end

  def self.schema_check( object, kind, schema = {}, path = [])
    kind = Kind.new(kind)

    failure = lambda{|message| raise Failure.new(message, object, kind, path) }

    case kind

    # simple values
    when IsDefinition["string"]
      failure["not a string"] unless object.is_a? String
    when IsDefinition["number"]
      failure["not a number"] unless object.is_a? Numeric
    when IsDefinition["boolean"]
      failure["not a boolean"] unless object == true || object == false
    when IsDefinition["null"]
      failure["not null"] unless object == nil
    when IsDefinition["undefined"]
      object == :undefined or failure["is not undefined"]

    # complex values
    when IsDefinition["array"]
      failure[ "not an array" ] unless object.is_a? Array
      object.each_with_index do |entry, i|
        if kind.contents?
          schema_check( entry, kind.contents, schema, path + [i] )
        end
      end

    when IsDefinition["object"]
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
    when IsDefinition["anything"]
      object != :undefined or failure[ "is not defined" ]

    when IsDefinition["literal"]
      object == kind.params or failure[ "doesn't match" ]

    when IsDefinition["integer"]
      schema_check( object, "number", schema, path)
      object.is_a?(Integer) or failure[ "is not an integer" ]

    when IsDefinition["enum"]
      kind.values!.find_index do |value|
        value == object
      end or failure["does not match any choice"]

    when IsDefinition["range"]
      failure["not a number"] unless object.is_a? Numeric
      bottom, top = kind.limits!
      failure["value out of range"] unless (bottom..top).include?(object)

    when IsDefinition["tuple"]
      schema_check( object, "array", schema, path )
      failure["tuple is the wrong size"] if object.length > kind.elements!.length
      undefineds = [:undefined] * (kind.elements!.length - object.length)
      kind.elements!.zip(object + undefineds).each_with_index do |pair, i|
        spec, value = pair
        schema_check( value, spec, schema, path + [i] )
      end

    when IsDefinition["dictionary"]
      schema_check( object, "object", schema, path )
      if kind.contents?
        object.each do |key, value|
          schema_check( value, kind.contents, schema, path + [key] )
        end
      end

    # set theory
    when IsDefinition["either"]
      kind.choices!.find_index do |choice|
        begin
          schema_check( object, choice, schema, path )
          true
        rescue Failure
          false
        end
      end or failure["does not match any choice"]

    when IsDefinition["optional"]
      object == :undefined or schema_check( object, kind.params, schema, path )

    when IsDefinition["restrict"]
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
    else
      if schema[kind.name]
        schema_check( object, schema[kind.name], schema, path )
      else
        raise "Invalid definition #{kind.inspect}"
      end
    end
  end
end

