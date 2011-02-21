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
      @desired.keys.each do |key|
        raise "#{key} doesn't match" unless @checker.check(key, @reader, @desired)
      end
      return true
    end

    def survey
      res = Poppet::Resource.new({ })
      @desired.keys.each do |key|
        res[key] = @reader[key]
      end
      puts JSON.dump(res.data)
    end
  end
end
