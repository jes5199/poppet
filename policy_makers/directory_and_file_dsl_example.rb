#!/usr/bin/ruby
require 'lib/policy/maker/dsl'
policy do
  dir = resource("directory", "dsl directory", :exists => true, :path => "/tmp/poppet.dsl")
  resource(      "file",      "dsl file",      :exists => true, :path => "/tmp/poppet.dsl/file",
    :content => "Hello, DSL world, from #{system(:hostname)}"
  ).after(dir)

  resource(      "file",   "dsl nudge file",   :exists => true,
    :path => "/tmp/poppet.dsl/nudge", :content => "hello."
  ).after("dsl directory").nudge("dsl file")
end
