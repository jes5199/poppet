require 'lib/resource'
module Poppet
  class Resource::System < Resource
    attr :data
    def initialize( facts )
      @data = {
        "version" => "0",
        "type" => "system",
        "data" => facts,
      }
      validate!
    end

    def self.schema
      Struct.schema_for( "system", "0", "object", "undefined", "resource", false )
    end
  end
end

