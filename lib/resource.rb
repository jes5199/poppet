require 'lib/struct'
module Poppet
  class Resource < Struct
    attr_reader :data

    def self.schema
      Struct.schema_for( "resource", "0", "object", ["optional", "object"], "struct", true )
    end

    def [](name)
      @data["Parameters"][name]
    end

    def []=(name, value)
      @data["Parameters"][name] = value
    end

    def keys
      @data["Parameters"].keys
    end

    def initialize( data = {}, pairs = nil )
      @data = self.class.empty_data.merge(data)
      @data["Parameters"] = @data["Parameters"].merge( pairs || {} )
      @data["Metadata"]   = @data["Metadata"].merge( {} ) if @data["Metadata"]
      validate!
    end

    def merge( h )
      self.class.new( @data, h )
    end

    def self.empty_data
      {
        "Version" => "0",
        "Type" => "resource",
        "Parameters" => {
        }
      }
    end
  end
end

