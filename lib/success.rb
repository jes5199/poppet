require 'lib/struct'
module Poppet
  class Success < Struct
    def self.schema
      schema_for( "success", "0", ["object", {"members" => {"success" => "boolean"} } ], "undefined" )
    end
  end
end
