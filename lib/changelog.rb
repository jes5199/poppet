require 'lib/struct'
require 'lib/resource'
module Poppet
  class Changelog < Struct

    def initialize( data = {}, history = [] )
      @data = self.class.empty_data
      @data = @data.merge(data)
      @data["Parameters"] = @data["Parameters"].merge( "history" => ( @data["Parameters"]["history"].dup ) )
      history.each do |entry|
        append!( entry )
      end
      validate!
    end

    def concat( other )
      self.class.new( {"Metadata" => @data["Metadata"] || {}}, self.history + other.history )
    end

    def append!(entry)
      change, resource, extra = entry
      if resource.is_a? Poppet::Resource
        resource = resource.to_hash
      end
      entry = [change, resource]
      if extra
        extra = extra.dup
        entry << extra
        extra["log"] ||= []
        extra["log"].map! do |event|
          event.each do |name, value|
            if value.is_a?(Time)
              event[name] = value.to_f
            end
          end
        end
      end

      history << entry
      self
    end

    def append( entry )
      self.class.new( {"Metadata" => @data["Metadata"] || {}}, self.history ).append!(entry)
    end

    def map(&blk)
      self.class.new( {}, history.map do |name, state|
        res = Poppet::Resource.new(state)
        blk.call( name, res )
      end )
    end

    def first_state
      Poppet::Resource.new( history.first[1] )
    end

    def last_state
      Poppet::Resource.new( history.last[1] )
    end

    def makes_change?
      history.find{|x| x.first }
    end

    def length
      history.length
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
