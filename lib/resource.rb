require 'lib/struct'
module Poppet
  class Resource < Struct
    def self.schema
      {
        "resource"    => ["restrict", {"require" => ["struct", "_resource_0"] } ], # TODO: build versioned eithers
        "_resource_0" => ["object",
          {
            "members" =>
              { "data"       => "_resource_data_0",
                "meta"       => "_resource_meta_0",
                "type"       => "string", # TODO: build eithers of known Types?
                "version"    => ["literal", "0"],
              },
          } ],
        "_resource_data_0" => "object", # Opaque to the abstract Resource class.
        "_resource_meta_0" => "object", # TODO: fill in valid params.
      }
    end
  end
end

