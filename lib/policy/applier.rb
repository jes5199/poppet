require 'lib/policy'
module Poppet
  class Policy::Applier
    def initialize( *args )
      @policy = Poppet::Policy.new( *args )
    end

    def hash_order(&blk)
      @policy.resources.each(&blk)
    end

    def shuffled(&blk)
      @policy.resources.to_a.shuffle.each(&blk)
    end

    def topsort(&blk)
      children_of = Hash.new{|h,k| h[k] = [] }
      num_parents = Hash.new{|h,k| h[k] = 0 }

      hash_order do |id, resource|
        num_parents[id]

        next unless resource["Metadata"]

        ( resource["Metadata"]["before"] || [] ).each do |other_id|
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

        level_parents.shuffle.each do |id|
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

    def each
      # TODO: frontier walking
      topsort do |id, resource|
        STDERR.puts id
        yield( Poppet::Resource.new( resource ) )
      end
    end
  end
end

