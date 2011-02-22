require 'rubygems'
require 'json'

require 'lib/resource'
require 'lib/implementor/reader'
require 'lib/implementor/checker'
require 'lib/implementor/writer'
require 'lib/implementor/solver'

include Poppet::Execute::EscapeWithLittleE

command, desired_json = JSON.parse( STDIN.read )
desired = Poppet::Resource.new( desired_json )

# Question: should we support finding files by things other than path?
if ! desired["path"]
  raise "Sorry, I don't support finding a file without a path."
end

# Find the file
reader = Poppet::Implementor::Reader.new({
  "path" => lambda { desired["path"] },

  "exists" => lambda { Poppet::Execute.execute_test( "test -e #{ e desired["path"] } " ) },

  "mode"   => [
    { "exists" => [ "literal", true ] },
    lambda { Poppet::Execute.execute( "stat -c %a #{ e desired["path"] }" ).chomp }
  ],

  "owner" => [
    { "exists" => [ "literal", true ] },
    lambda { Poppet::Execute.execute( "stat -c %U #{ e desired["path"] }" ).chomp }
  ],

  "group" => [
    { "exists" => [ "literal", true ] },
    lambda { Poppet::Execute.execute( "stat -c %G #{ e desired["path"] }" ).chomp }
  ],

  "content" => [
    { "exists" => [ "literal", true ] },
    lambda { Poppet::Execute.execute( "cat #{ e desired["path"] }" ) }
  ],

  "checksum" => [
    { "exists" => [ "literal", true ] },
    lambda { Poppet::Execute.execute( "md5sum #{ e desired["path"] }" ).sub(/\s.*/m, "") }
  ]
})

def simulated_chmod( old, new)
  new #TODO: smart chmods
end

checker = Poppet::Implementor::Checker.new({
  "path"     => lambda{ |actual_value, desired_value| actual_value == desired_value },
  "exists"   => lambda{ |actual_value, desired_value| actual_value == desired_value },
  "content"  => lambda{ |actual_value, desired_value| actual_value == desired_value },
  "checksum" => lambda{ |actual_value, desired_value| actual_value == desired_value },

  "owner"    => lambda{ |actual_value, desired_value| numeric_user(  desired_value ) == numeric_user(  actual_value ) },
  "group"    => lambda{ |actual_value, desired_value| numeric_group( desired_value ) == numeric_group( actual_value ) },

  "mode"     => lambda do |actual_value, desired_value|
                 simulated_chmod( actual_value, desired_value ) == actual_value
                end,
})

def write_file( w, desired )
  #TODO: sudo
  #TODO: umode
  w.execute( "echo #{ e desired["content"] } > #{ e desired["path"] } " )
end

writer = Poppet::Implementor::Writer.new([ # state machine
  [
    {"exists" => ["literal", true]},
    lambda do |w, actual, desired|
      w.execute( "rm #{ e desired["path"] }" ) # in traditional unix style, let's remove files and symlinks but not directories.
      {
        "path" => desired["path"],
        "exists" => false
      }
    end
  ],

  [
    {"exists" => ["literal", false]},
    lambda do |w, actual, desired|
      write_file( w, desired )
      {
        "exists"  => true,
        "path"    => desired["path"],
        "mode"    => desired["mode"],
        "owner"   => desired["owner"],
        "content" => desired["content"]
      }
    end
  ],

  [
    { "exists" => ["literal", true], "content" => "string" },
    lambda do |w, actual, desired|
      write_file( w, desired )
      actual.merge( "content" => desired["content"] )
    end
  ],

  [
    { "exists" => ["literal", true], "mode" => "string" },
    lambda do |w, actual, desired|
      mod = simulated_chmod( actual["mode"], desired["mode"] )
      w.execute( "chmod #{e desired["mode"] } #{ e desired["path"] }" )
      actual.merge( "mode" => mod )
    end
  ],

  [
    { "exists" => ["literal", true], "owner" => "string" },
    lambda do |w, actual, desired|
      w.execute( "chown #{e desired["owner"] }, #{e desired["path"] } " )
      actual.merge( "owner" => desired["owner"] )
    end
  ],

  [
    { "exists" => ["literal", true], "group" => "string" },
    lambda do |w, actual, desired|
      w.execute( "chown #{e desired["group"]} #{e desired["path"]} " )
      actual.merge( "group" => desired["group"] )
    end
  ]
])

require 'pp'
pp Poppet::Implementor::Solver.new( reader, desired, checker, writer ).do( command )
# TODO: print out json
