require 'lib/policy'
require 'lib/changelog'
require 'lib/implementor'
require 'sha1'

module Poppet
  class Policy::Applier
    attr :imp
    def initialize( policy_struct, options = {} )
      @policy = Poppet::Policy.new( policy_struct )
      @options = options.dup
      @imp = Poppet::Implementor.new( options["implement"] )
    end

    def self.default_algorithm
      :frontier_walk
    end

    def algorithm
      @options["algorithm"] || self.class.default_algorithm
    end

    def using_algorithm(&blk)
      self.send(algorithm, &blk)
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

        resources_before(id).each do |other_id|
          children_of[id] << other_id
          num_parents[other_id] += 1
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
      ( @policy.resources[id].metadata['after']     || [] ) + \
      ( @policy.resources[id].metadata['nudged_by'] || [] ) + \
      @policy.resources.find_all do |id2, res|
        ( res.metadata['before'] || [] ).include?(id) || \
        ( res.metadata['nudge'] || [] ).include?(id)
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

    def one_armed_man(&blk)
      # Experimental
      require 'lib/policy/applier/one_armed_man.rb'
      searcher = Policy::Applier::OneArmedMan.for_policy( @policy, &blk )
      searcher.search
    end

    def each
      using_algorithm do |id, resource|
        STDERR.puts id
        yield( id, resource )
      end
    end

    def implement( resource, simulate, nudge )
      action = case
        when simulate && nudge
          'simulate_nudge'
        when !simulate && nudge
          'nudge'
        when simulate && !nudge
          'simulate'
        else
          'change'
        end
      data = [action, resource.data]
      changes_data = imp.execute( data )
      changes = Poppet::Changelog.new(changes_data)
    end

    def apply
      history = Poppet::Changelog.new( {"Metadata" => @options["metadata"]} )
      nudges = {}
      changed = {}
      self.each do |id, res|
        nudge = @options["always_nudge"] || nudges[id] || (res.metadata["nudged_by"] || []).any?{|nudged_by| changed[nudged_by]}
        simulate = @options["dry_run"]
          changes = implement( res, simulate, nudge )
          if changes.makes_change?
            ( res.metadata["nudge"] || [] ).each do |nudge_id|
              STDERR.puts "nudges: #{nudge_id.inspect}"
              nudges[nudge_id] = true
            end
            changed[id] = true
          end
        history = history.concat( changes )
      end
      return history
    end
  end
end

