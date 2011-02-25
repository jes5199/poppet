require 'lib/resource'
require 'lib/implementor/implementation'

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
      end
    end

    def check
      diff = find_differences( @reader, @desired )
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
        "type"    => @desired.data["type"],
        "version" => @desired.data["version"],
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

    def replay( changes )
      real_state = changes.first[1]
      changes.map do |rule_name, simulated_result|
        if rule_name
          real_state = @writer.change( @writer.rules[rule_name], real_state, @desired )
        end

        if @paranoid and diff = find_differences( real_state, simulated_result )
          raise "something went wrong: #{diff}"
        end

        [rule_name , state]
      end
    end

    def solve( starting_state, max_depth = 10 )
      # breadth-first search: simulate all possible writes
      choices = [ [ [nil, starting_state] ] ]
      max_depth.times do
        choices = choices.map do |history|
          state = history.last.last
          return history if ! find_difference( state, @desired )

          @writer.rules.map do |name, rule|
            new_state = @writer.simulate( rule, state, @desired )
            new_history = history + [[name, new_state]]
            next new_history unless new_state.nil?
          end.compact

        end.inject([]){|a,b| a + b}
      end
      raise "no solution found."
    end
  end
end
