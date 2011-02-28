require 'lib/struct'
require 'lib/resource'
module Poppet
  class Changelog < Struct

    def initialize( data = {}, history = [] )
      @data = self.class.empty_data
      @data = @data.merge(data)
      history = history.map do |change, resource|
        if resource.is_a? Poppet::Resource
          resource = resource.to_hash
        end
        [change, resource]
      end
      @data["Parameters"] = @data["Parameters"].merge( "history" => ( @data["Parameters"]["history"] + history ) )
      validate!
    end

    def concat( other )
      self.class.new( {"Metadata" => @data["Metadata"] || {}}, self.history + other.history )
    end

    def append( entry )
      change, resource = entry
      if resource.is_a? Poppet::Resource
        resource = resource.to_hash
      end
      entry = [change, resource]
      self.class.new( {"Metadata" => @data["Metadata"] || {}}, self.history + [entry] )
    end

    def map(&blk)
      self.class.new( {}, history.map do |name, state|
        res = Poppet::Resource.new(state)
        blk.call( name, res )
      end )
    end

    def first_state
      Poppet::Resource.new( history.first.last )
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
