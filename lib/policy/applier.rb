require 'lib/policy'
module Poppet
  class Policy::Applier
    def initialize( *args )
      @policy = Poppet::Policy.new( *args )
    end

    def each
      # TODO: frontier walking
      @policy.resources.to_a.shuffle.each do |id, resource|
        STDERR.puts id
        yield(resource)
      end
    end
  end
end

