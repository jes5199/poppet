require 'lib/implementor/implementation'

module Poppet
  class Implementor::Checker
    def check(name, actual, desired)
      method = self.class.checker_for(name)
      if self.respond_to? method
        send( method, actual, desired )
      else
        actual == desired
      end
    end

    def self.checkers(*args)
      @checkers ||= {}
      if args.last.is_a?(Hash)
        args.pop.each do |name, method|
          @checkers[name.to_s] = method.to_sym
        end
      end
      args.each do |name|
        @checkers[name.to_s] = name.to_sym
      end
    end

    def self.checker_for(name)
      @checkers[name.to_s]
    end

  end
end
