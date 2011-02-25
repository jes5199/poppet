require 'lib/struct'
module Poppet
  class Resource < Struct
    attr_reader :data

    def self.schema
      Struct.schema_for( "resource", "0", "object", ["optional", "object"], "struct", true )
    end

    def [](name)
      @data["data"][name]
    end

    def []=(name, value)
      @data["data"][name] = value
    end

    def keys
      @data["data"].keys
    end

    def initialize( data = {}, pairs = nil )
      @data = self.class.empty_data.merge(data)
      @data["data"] = @data["data"].merge( pairs || {} )
      @data["meta"] = @data["meta"].merge( {} ) if @data["meta"]
      validate!
    end

    def merge( h )
      self.class.new( @data, h )
    end

    def to_json
      @data.to_json
    end

    def self.empty_data
      {
        "version" => "0",
        "type" => "resource",
        "data" => {
        }
      }
    end
  end
end

