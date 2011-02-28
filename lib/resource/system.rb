require 'lib/resource'
module Poppet
  class Resource::System < Resource
    attr :data
    def initialize( data = {}, facts = {} )
      @data = {
        "Version" => "0",
        "Type" => "system",
        "Parameters" => {},
        "Metadata"   => {},
      }.merge(data)
      @data["Parameters"].merge(facts)
      validate!
    end

    def self.schema
      Struct.schema_for( "system", "0", "object", ["optional", "object"], "resource", false )
    end
  end
end

