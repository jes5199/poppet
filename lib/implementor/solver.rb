require 'lib/resource'
require 'lib/implementor/implementation'
require 'lib/changelog'

module Poppet
  class Implementor::Solver < Implementor::Implementation
    def initialize( desired, reader, checker, writer )
      @desired, @reader, @checker, @writer = desired, reader, checker, writer
    end

    def do( command )
      case command
        when "check"    then check
        when "survey"   then survey
        when "simulate" then simulate
        when "change"   then change
        when "nudge"    then nudge
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
        return "#{key} is #{state[key]}, doesn't match #{des[key]}" unless @checker.check(key, state, des)
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

    def simulate
      resource = survey
      solve( resource )
    end

    def change
      changes = simulate
      replay( changes )
    end

    def nudge
      changes = simulate
      if changes.length <= 1 and @writer.rules["nudge"]
        state = changes.first_state
        new_state = @writer.simulate( @writer.rules["nudge"], state, @desired )
        if ! find_difference( state, new_state )
          STDERR.puts "nudging"
          new_state = @writer.change( @writer.rules["nudge"], state, @desired )
          if new_state
            return changes.append( ["nudge", new_state] )
          end
        end
      end
      replay( changes )
    end

    def replay( changes )
      real_state = changes.first_state
      changes.map do |rule_name, simulated_result|
        if rule_name
          real_state = @writer.change( @writer.rules[rule_name], real_state, @desired )
        end

        if @paranoid and diff = find_difference( real_state, simulated_result )
          raise "something went wrong: #{diff}"
        end

        [rule_name, real_state]
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

          @writer.rules.map do |name, rule|
            new_state = @writer.simulate( rule, state, @desired )
            new_history = history.append( [name, new_state] )
            next new_history unless new_state.nil?
          end.compact

        end.inject([]){|a,b| a + b}
      end
      raise "no solution found."
    end
  end
end
