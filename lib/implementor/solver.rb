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
      res = new_resource
      @desired.keys.each do |key|
        res[key] = @reader[key]
      end
      res
    end

    def simulate
      survey
      changes, res = solve
      [ changes, new_resource(res) ]
    end

    def change
      simulate
      # TODO apply changes.
    end

    def solve( max_depth = 10 )
      # breadth-first search: simulate all possible writes
      choices = [ [ [], @reader ] ]
      max_depth.times do
        choices = choices.map do |history, state|
          @writer.rules.map do |rule|
            path = history + [rule]
            result = @writer.simulate( rule, state, @desired )
            unless result.nil?
              return [path, result] if ! find_difference( result, @desired )
              [
                ( history + [rule] ), result
              ]
            end
          end.compact
        end.inject([]){|a,b| a+b}
      end
      raise "no solution found."
    end
  end
end
