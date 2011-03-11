require 'rubygems'
require 'json'

require 'lib/resource'
require 'lib/implementor/reader'
require 'lib/implementor/checker'
require 'lib/implementor/writer'
require 'lib/implementor/solver'

include Poppet::Execute::EscapeWithLittleE
include Poppet::Execute::ExecuteWithLittleX

class << self
  attr_writer :reader_class, :writer_class, :checker_class
end
def implementor
  command, desired_json = JSON.parse( STDIN.read )
  desired = Poppet::Resource.new( desired_json )

  yield(desired)

  reader = @reader_class.new(desired)
  checker = @checker_class.new
  writer = @writer_class.new(desired)

  puts Poppet::Implementor::Solver.new( desired, reader, checker, writer ).do( command ).to_json
end
