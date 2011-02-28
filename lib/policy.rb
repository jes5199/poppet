require 'lib/struct'
require 'lib/resource'

module Poppet
  class Policy < Struct
    attr_reader :data
    def initialize( data = {}, name = nil )
      @data = self.class.empty_data.merge(data)
      @data["Parameters"]["name"] = name if name
      validate!
    end

    def related_classes
      [ Poppet::Resource ]
    end

    def self.schema
      Struct.schema_for(
        "policy", "0",
        ["object", {
          "resources" => ["dictionary", {"contents" => "resource"} ],
          "name"      => "string",
        }],
        ["optional", "object"]
      )
    end

    def self.empty_data
      {
        "Version" => "0",
        "Type" => "policy",
        "Parameters" => {
          "resources" => {},
          "name"      => "",
        }
      }
    end
    def resources
      @data["Parameters"]["resources"]
    end

    def orderings
      @data["Parameters"]["orderings"]
    end

    def name
      @data["Parameters"]["name"]
    end

    def combine( other )
      Policy.new(
        "Parameters" => {
          "resources"=> combine_resources( self.resources, other.resources ),
          "name"     => self.name || other.name,
        },
        "Metadata" => self.data["Metadata"]
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
