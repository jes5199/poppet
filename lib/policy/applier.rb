require 'lib/policy'
module Poppet
  class Policy::Applier
    def initialize( *args )
      @policy = Poppet::Policy.new( *args )
    end

    def each
      # TODO: frontier walking
      @policy.resources.each do |id, resource|
        yield(resource)
      end
    end
  end
end

