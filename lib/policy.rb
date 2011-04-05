require 'lib/struct'
require 'lib/resource'
require 'lib/monkey_patches/hash_map'

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
      @data["Parameters"]["resources"].value_map{|k,r| Poppet::Resource.new(r) }
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

    def resources_before( id )
      res = id.is_a?(String) ? self.resources[id] : self.resources[id[0]].possible_transient_states[id[1]]

      ( res.metadata['after']     || [] ) + \
      ( res.metadata['nudged_by'] || [] ) + \
      self.resources.find_all do |id2, res2|
        ( res2.metadata['before'] || [] ).include?(id) || \
        ( res2.metadata['nudge']  || [] ).include?(id)
      end.map{|id2, res| id2 }
    end

    def do_not_change_unless
      self.metadata['do_not_change_unless'] || []
    end

    def transient_resources
      r = {}
      self.resources.each do |name, res|
        res.possible_transient_states.each{|subname, t_res| r[[name,subname]] = t_res}
      end
      return r
    end

    def resources_and_transients
      resources.merge( transient_resources )
    end

    private
    def combine_resources(r1, r2)
      dups = r1.keys & r2.keys
      raise "duplicate resource keys #{dups.inspect}" if ! dups.empty?
      r1.merge(r2)
    end
  end
end
