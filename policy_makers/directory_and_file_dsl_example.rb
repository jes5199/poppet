#!/usr/bin/ruby
require 'lib/policy/maker/dsl'
policy do
  dir = resource("directory", "dsl directory", :exists => true, :path => "/tmp/poppet.dsl")
  resource(      "file",      "dsl file",      :exists => true, :path => "/tmp/poppet.dsl/file",
    :content => "Hello, DSL world, from #{system(:hostname)}"
  ).after(dir)
end
