require 'lib/struct'
require 'lib/resource'
module Poppet
  class Changelog < Struct

    def initialize( history = [] )
      @data = self.class.empty_data
      history = history.map do |change, resource|
        if resource.is_a? Poppet::Resource
          resource = resource.to_hash
        end
        [change, resource]
      end
      @data["Parameters"] = @data["Parameters"].merge( "history" => history )
      validate!
    end

    def append( entry )
      change, resource = entry
      if resource.is_a? Poppet::Resource
        resource = resource.to_hash
      end
      entry = [change, resource]
      self.class.new( self.history + [entry] )
    end

    def last_state
      Poppet::Resource.new( history.last.last )
    end

    def history
      @data["Parameters"]["history"]
    end

    def self.schema
      Struct.schema_for( "changelog", "0",
      [
        "object", {"members" => { "history" =>
          ["array",
            {
              "elements" => [ "tuple", { "members" => [ [ "either", {"choices" => ["string", "null"]} ], "resource", ["optional", "object"] ] } ]
            }
          ]
        } }
      ],
      ["optional", "object"],
      "struct", true )
    end

    def related_classes
      [ Poppet::Resource ]
    end

    def self.empty_data
      {
        "Version" => "0",
        "Type" => "changelog",
        "Parameters" => {
          "history" => []
        }
      }
    end

  end
end
