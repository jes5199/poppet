require 'lib/struct'
module Poppet
  class Policy < Struct # FIXME
    attr_reader :data
    def initialize( data = {}, name = nil )
      @data = self.class.empty_data.merge(data)
      @data["data"]["name"] = name if name
      validate
    end

    def self.schema
      {
        "policy"    => ["restrict", {"require" => ["struct", "_policy_0"] } ], # TODO: build versioned eithers
        "_policy_0" => ["object",
          {
            "members" =>
              { "data"       => "_policy_data_0",
                "meta"       => "undefined",
                "type"       => ["literal", "policy"],
                "version"    => ["literal", "0"],
              },
          } ],
        "_policy_data_0" => [ "object", { "members" =>
          {
            "resources" => "dictionary", # FIXME: of resources
            "name"      => "string",
          } } ],
      }
    end

    def self.empty_data
      {
        "version" => "0",
        "type" => "policy",
        "data" => {
          "resources" => {},
          "name"      => "",
        }
      }
    end
    def resources
      @data["data"]["resources"]
    end

    def orderings
      @data["data"]["orderings"]
    end

    def name
      @data["data"]["name"]
    end

    def combine( other )
      Policy.new(
        "data" => {
          "resources"=> combine_resources( self.resources, other.resources ),
          "name"     => self.name || other.name,
        }
      )
    end

    private
    def combine_resources(r1, r2)
      dups = r1.keys - r2.keys
      raise "duplicate resource keys #{dups.inspect}" if ! dups.empty?
      r1.merge(r2)
    end
  end
end
