require 'lib/resource'
require 'lib/changelog'

module Poppet
  class Implementor::Solver
    def initialize( desired, reader, checker, writer )
      @desired, @reader, @checker, @writer = desired, reader, checker, writer
    end

    def do( command )
      case command
        when "check"          then check
        when "survey"         then survey
        when "simulate"       then simulate
        when "simulate_nudge" then simulate(true)
        when "change"         then change
        when "nudge"          then nudge
      end
    end

    def check
      diff = find_difference( @reader, @desired )
      raise diff if diff
      return true
    end

    def find_difference( state, des )
      des.keys.each do |key|
        next if des[key].nil?
        return "#{key} is #{state[key]}, doesn't match #{des[key]}" unless @checker.check(key, state[key], des[key])
      end
      return nil
    end

    def new_resource( pairs = {} )
      res = Poppet::Resource.new({
        "Type"    => @desired.data["Type"],
        "Version" => @desired.data["Version"],
      }, pairs )
    end

    def survey
      res = new_resource( @reader.get( @desired.keys ) )
    end

    def simulate( nudge = false )
      resource = survey
      changes = solve( resource )

      changes = try_to_add_nudge(changes) if nudge

      changes
    end

    def try_to_add_nudge(changes)
      if ! changes.makes_change?
        state = changes.first_state
        new_state, logs = @writer.simulate( "nudge", state )
        if ! find_difference( state, new_state )
          new_state, logs = @writer.change( "nudge", state )
          if new_state
            return changes.append( ["nudge", new_state] )
          end
        end
      end
      changes
    end

    def change( nudge = false )
      changes = simulate(nudge)
      replay( changes )
    end

    def nudge
      change(true)
    end

    def replay( changes )
      real_state = changes.first_state
      changes.map do |rule_name, simulated_result|
        start_time = Time.now
        if rule_name
          real_state, log = @writer.change( rule_name, real_state )
        end

        if @paranoid and diff = find_difference( real_state, simulated_result )
          raise "something went wrong: #{diff}"
        end

        stop_time = Time.now
        [rule_name, real_state, { "log" => log , "start_time" => start_time.to_f, "stop_time" => stop_time.to_f } ]
      end
    end

    def solve( starting_state, max_depth = 10 )
      # breadth-first search: simulate all possible writes

      changelog = Poppet::Changelog.new( {}, [ [ nil, starting_state ] ] )
      choices = [ changelog ]
      max_depth.times do
        choices = choices.map do |history|
          state = history.last_state
          return history if ! find_difference( state, @desired )

          @writer.action_list.map do |action|
            new_state, log = @writer.simulate( action, state )
            new_history = history.append( [action, new_state, {"log" => log}] )
            next new_history unless new_state.nil?
          end.compact

        end.inject([]){|a,b| a + b}
      end
      raise "no solution found."
    end
  end
end
