require 'lib/policy'
require 'sha1'

module Poppet
  class Policy::Applier
    def initialize( policy_struct, options = {} )
      @policy = Poppet::Policy.new( policy_struct )
      @options = options.dup
    end

    def shuffle_key( name )
      if @options["order_resources_by_name"]
        name
      else
        Digest::SHA1.digest( @options["shuffle_salt"].to_s + name )
      end
    end

    def hash_order(&blk)
      @policy.resources.each(&blk)
    end

    def shuffled(&blk)
      @policy.resources.to_a.sort_by{|name, res| shuffle_key(name) }.each(&blk)
    end

    def topsort(&blk)
      children_of = Hash.new{|h,k| h[k] = [] }
      num_parents = Hash.new{|h,k| h[k] = 0 }

      hash_order do |id, resource|
        num_parents[id]

        next unless resource["Metadata"]

        ( ( resource["Metadata"]["before"] || [] ) + (resource["Metadata"]["nudge"] || []) ).each do |other_id|
          children_of[id] << other_id
          num_parents[other_id] += 1
        end
        ( resource["Metadata"]["after"] || [] ).each do |other_id|
          children_of[other_id] << id
          num_parents[id] += 1
        end
      end

      loop do
        level_parents = num_parents.keys.find_all{|x| num_parents[x] == 0 }

        break if level_parents.empty?

        level_parents.sort_by{|id| shuffle_key(id) }.each do |id|
          blk.call( id, @policy.resources[id] )
        end

        level_parents.each do |level_parent|
          num_parents.delete(level_parent)

          if children_of[level_parent]
            children_of[level_parent].each do |level_parent_child|
              num_parents[level_parent_child] -= 1
            end
            children_of.delete(level_parent)
          end
        end
      end

      if ! num_parents.empty?
        raise "cycle"
      end
    end

    def resources_before(id)
      ( ( @policy.resources[id]['Metadata'] || {} )['after'] || [] ) + \
      @policy.resources.find_all do |id2, res|
        ( ( res['Metadata'] || {} )['before'] || [] ).include?(id)
      end.map{|id2, res| id2 }
    end

    def frontier_walk(&blk)
      done = Hash.new
      loop do
        count = 0
        shuffled do |id, res|
          next if done[id]

          next if resources_before(id).find{ |before| ! done[before] }

          blk.call(id, res)

          count += 1
          done[id] = true
        end
        break if count == 0
      end
    end

    def each
      frontier_walk do |id, resource|
        STDERR.puts id
        resource_object = Poppet::Resource.new( resource )
        yield( id, resource_object )
      end
    end
  end
end

