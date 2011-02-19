require 'lib/policy'
module Poppet
  class Policy::Applier < Policy
    def each
      # TODO: frontier walking
      resources.each do |resource|
        yield(resource)
      end
    end
  end
end

