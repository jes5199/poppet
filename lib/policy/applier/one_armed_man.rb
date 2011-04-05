require 'vendor/astar/astar.rb'
module Poppet
  class Policy::Applier::OneArmedMan < AStar
    class LiveResource
      def initialize(imp, resource)
        # or something.
      end

      def matches?(desired_resource)
        # call check on imp
      end

      def simulate(desired_resource)
        # call simulate on the imp
        # return an AlteredResource of the last state
      end
    end

    class AlteredResource < LiveResource
      def matches?(desired_resource)

      end

      def simulate(desired_resource)
        # call simulate2 on the imp
        # return an AlteredResource of the last state
      end
    end

    class WorldVertex
      def initialize(policy, state, done = [])
        @policy = policy
        @state  = state
        @done   = done
      end

      def resource_blocked_by_before(name)
        @policy.resources_before(name).find{ |blocker| ! @done[blocker] }
      end

      def allowable_state_changes(name)
        @policy.resources_and_transients[name].do_not_change_unless.find_all{ |change_rule| rule_is_satisfied?( change_rule ) }
      end

      def rule_is_satisfied?( change_rule )
        # A change rule is a sort of tuple, I guess
        my_actions, requirement   = change_rule
        required_resource_name, _ = requirement
        resource_okay?( @state[required_resource_name], @policy.resources_and_transients[requirement] )
      end

      def resource_okay?( current_resource, desired_resource )
        ! current_resource.matches?(desired_resource)
      end

      def can_do_resource?(name)
        ! resource_blocked_by_before?(name) and ! allowable_state_changes(name).empty?
      end

      def possible_actions
        (@policy.resources_and_transients.keys - done).find_all { |name| can_do_resource?(name) }
      end
    end

    def self.for_policy(policy)
      self.new( WorldState.new(policy) )
    end

    def neighbors(world)
      WorldState.possible_actions
    end

    def edge_cost(from, to)

    end

    def heuristic(from)

    end

  end
end
