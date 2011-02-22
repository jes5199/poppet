require 'lib/resource'
require 'lib/implementor/implementation'

module Poppet
  class Implementor::Solver < Implementor::Implementation
    def initialize( reader, desired, checker, writer )
      @reader, @desired, @checker, @writer = reader, desired, checker, writer
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
        return "#{key} is #{state[key]}, doesn't match #{des[key]}" unless @checker.check(key, state, des)
      end
      return nil
    end

    def survey
      res = Poppet::Resource.new({ })
      @desired.keys.each do |key|
        res[key] = @reader[key]
      end
      puts JSON.dump(res.data)
    end

    def simulate
      solve
    end

    def change
      solve
      # TODO apply changes.
    end

    def solve( max_depth = 10 )
      # breadth-first search: simulate all possible writes
      choices = [ [ @reader, [] ] ]
      max_depth.times do
        p choices
        choices = choices.map do |actual, history|
          @writer.rules.map do |rule|
            path = history + [rule]
            results = @writer.simulate( rule, actual, @desired )
            unless results.nil?
              return path if ! find_difference( results, @desired )
              [
                results, ( history + [rule] )
              ]
            end
          end.compact
        end.inject([]){|a,b| a+b}
      end
      raise "no solution found."
    end
  end
end
