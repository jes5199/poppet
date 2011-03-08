require 'lib/implementor/implementation'

module Poppet
  class Implementor::Reader
    attr_reader :desired
    def initialize(desired)
      @desired = desired
      @known   = {}

      self.class.each_reader do |name,method|
        (class << self; self ; end).instance_eval do
          define_method( method ) do
            @known[name] ||= super
          end
        end
      end
    end

    def self.readers(*args)
      @readers ||= {}
      if args.last.is_a?(Hash)
        args.pop.each do |name, method|
          @readers[name.to_s] = method.to_sym
        end
      end
      args.each do |name|
        @readers[name.to_s] = name.to_sym
      end
    end

    def self.each_reader
      @readers.each do |name, method|
        yield(name, method)
      end
    end

    def self.reader_for(name)
      @readers[name.to_s]
    end

    def [](name)
      send( self.class.reader_for(name) )
    end

    def get(keys)
      keys.each do |key|
        self[key]
      end
      to_hash
    end

    def to_hash
      Hash.new.merge( @known )
    end

    def merge( hash )
      to_hash.merge(hash)
    end

  end
end
