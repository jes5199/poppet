require 'lib/struct'
module Poppet
  class Resource::System < Resource
    def self.schema
      {
        "resource::system"  => ["restrict", {"require" => ["resource", "_resource::system"] } ], # TODO: "inherits" on "object" ?
        "_resource::system" => "object",
        # TODO: data is a dictionary
        # TODO: meta is undefined
      }
    end
  end
end

