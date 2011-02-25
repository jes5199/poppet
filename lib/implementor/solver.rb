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
      real_resulting_resource = replay( changes, @reader )
      [ changes, real_resulting_resource ]
    end

    def replay( changes, resource )
      state = resource
      changes.each do |action, result|
        state = @writer.change( action, state, @desired )

        if @paranoid and diff = find_differences( state, result )
          raise "something went wrong: #{diff}"
        end

      end
      state
    end

    def solve( starting_state, max_depth = 10 )
      # breadth-first search: simulate all possible writes
      choices = [ [ [[], starting_state] ] ]
      max_depth.times do
        choices = choices.map do |history|
          state = history.last.last
          return history if ! find_difference( state, @desired )

          @writer.rules.map do |rule|
            new_state = @writer.simulate( rule, state, @desired )
            new_history = history + [rule, new_state]
            next new_history unless new_state.nil?
          end.compact

        end
      end
      raise "no solution found."
    end
  end
end
