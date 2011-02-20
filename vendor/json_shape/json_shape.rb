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
      @name, @params = kind
      @params ||= {}
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

  def self.schema_check( object, kind, schema = {})
    kind = Kind.new(kind)

    case kind

    # simple values
    when IsDefinition["string"]
      raise "not a string" unless object.is_a? String
    when IsDefinition["number"]
      raise "not a number" unless object.is_a? Numeric
    when IsDefinition["boolean"]
      raise "not a boolean" unless object == true || object == false
    when IsDefinition["null"]
      raise "not null" unless object == nil
    when IsDefinition["undefined"]
      object == :undefined or raise "#{object.inspect} is defined"

    # complex values
    when IsDefinition["array"]
      raise "not an array" unless object.is_a? Array
      object.each do |entry|
        if kind.contents?
          schema_check( entry, kind.contents, schema )
        end
      end

    when IsDefinition["object"]
      object.is_a?(Hash) or raise "#{object.inspect} is not an object"
      if kind.members?
        kind.members.each do |name, spec|
          val = object.has_key?(name) ? object[name] : :undefined
          next if val == :undefined and kind.allow_missing
          schema_check( val, spec, schema )
        end
        if kind.allow_extra != true
          extras = object.keys - kind.members.keys
          raise "#{extras.inspect} are not valid members" if extras != []
        end
      end

    # obvious extensions
    when IsDefinition["anything"]
      object != :undefined or raise "#{object.inspect} is undefined"

    when IsDefinition["literal"]
      object == kind.params or raise "#{object.inspect} != #{kind.params.inspect}"

    when IsDefinition["integer"]
      schema_check( object, "number", schema )
      object.is_a?(Integer) or raise "#{object.inspect} is not an integer"

    when IsDefinition["enum"]
      kind.values!.find_index do |value|
        value == object
      end or raise "does not match any of #{kind.values.inspect}"

    when IsDefinition["range"]
      raise "not a number" unless object.is_a? Numeric
      bottom, top = kind.limits!
      raise "value out of range" unless (bottom..top).include?(object)

    when IsDefinition["tuple"]
      schema_check( object, "array", schema )
      raise "tuple is the wrong size" if object.length > kind.elements!.length
      undefineds = [:undefined] * (kind.elements!.length - object.length)
      kind.elements!.zip(object + undefineds).each do |spec, value|
        schema_check( value, spec, schema )
      end

    when IsDefinition["dictionary"]
      schema_check( object, "object", schema )
      schema_check( object.values, ["array", kind.params], schema )

    # set theory
    when IsDefinition["either"]
      kind.choices!.find_index do |choice|
        begin
          schema_check( object, choice, schema )
          true
        rescue
          false
        end
      end or raise "#{object.inspect} does not match any of #{kind.choices.inspect}"

    when IsDefinition["optional"]
      object == :undefined or schema_check( object, kind.params, schema )

    when IsDefinition["restrict"]
      if kind.require?
        kind.require.each do |requirement|
          schema_check( object, requirement, schema )
        end
      end
      if kind.reject?
        kind.reject.each do |rule|
          begin
            schema_check( object, rule, schema )
            false
          rescue
            true
          end or raise "#{object.inspect} violates #{rule.inspect}"
        end
      end

    # custom types
    else
      if schema[kind.name]
        schema_check( object, schema[kind.name], schema )
      else
        raise "Invalid definition #{kind.inspect}"
      end
    end
  end
end

