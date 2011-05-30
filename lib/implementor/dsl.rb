require 'rubygems'
require 'json'

require 'lib/resource'
require 'lib/implementor/reader'
require 'lib/implementor/checker'
require 'lib/implementor/writer'
require 'lib/implementor/solver'

class Poppet::Implementor::DSLSandbox
  include Poppet::Execute::EscapeWithLittleE
  include Poppet::Execute::ExecuteWithLittleX

  attr_accessor :reader_class, :writer_class, :checker_class
end

def implementor
  command, desired_json = JSON.parse( STDIN.read )
  desired = Poppet::Resource.new( desired_json )

  box = Poppet::Implementor::DSLSandbox.new
  box.instance_eval{ yield(desired) }

  reader = box.reader_class.new(desired)
  checker = box.checker_class.new
  writer = box.writer_class.new(desired)

  puts Poppet::Implementor::Solver.new( desired, reader, checker, writer ).do( command ).to_json
end
