require 'rubygems'
require 'json'

require 'lib/resource'
require 'lib/implementor/reader'
require 'lib/implementor/checker'
require 'lib/implementor/writer'
require 'lib/implementor/solver'

command, desired_json = JSON.parse( STDIN.read )
desired = Poppet::Resource.new( desired_json )

# Question: should we support finding files by things other than path?
if ! desired["path"]
  raise "Sorry, I don't support finding a file without a path."
end

def execute_test(*args)
  `#{args.join(" ")}` # FIXME
  $? == 0
end
def execute(*args)
  `#{args.join(" ")}` # FIXME
end

# Find the file
reader = Poppet::Implementor::Reader.new({
  "path" => lambda { desired["path"] },

  "exists" => lambda { execute_test( "test", "-e", desired["path"] ) ; },

  "mode"   => [
    { "exists" => [ "literal", true ] },
    lambda { execute( "stat -c %a", desired["path"] ).chomp }
  ],

  "owner" => [
    { "exists" => [ "literal", true ] },
    lambda { execute( "stat -c %U", desired["path"] ).chomp }
  ],

  "group" => [
    { "exists" => [ "literal", true ] },
    lambda { execute( "stat -c %G", desired["path"] ).chomp }
  ],

  "content" => [
    { "exists" => [ "literal", true ] },
    lambda { p desired; execute( "cat", desired["path"] ) }
  ],

  "checksum" => [
    { "exists" => [ "literal", true ] },
    lambda { execute( "md5sum", desired["path"] ).sub(/\s.*/m, "") }
  ]
})

checker = Poppet::Implementor::Checker.new({
  "path"     => lambda{ |actual_value, desired_value| actual_value == desired_value },
  "exists"   => lambda{ |actual_value, desired_value| actual_value == desired_value },
  "content"  => lambda{ |actual_value, desired_value| actual_value == desired_value },
  "checksum" => lambda{ |actual_value, desired_value| actual_value == desired_value },

  "owner"    => lambda{ |actual_value, desired_value| numeric_user(  desired_value["owner"] ) == numeric_user(  actual_value["owner"] ) },
  "group"    => lambda{ |actual_value, desired_value| numeric_group( desired_value["owner"] ) == numeric_group( actual_value["owner"] ) },

  "mode"     => lambda do |actual_value, desired_value|
                 simulated_chmod( actual_value["mode"], desired_value["mode"] ) == actual_value["mode"]
                end,
})

def write_file( w, desired )
  #TODO: sudo
  #TODO: umode
  w.execute( "echo", desired["content"], :output => desired["path"] )
end

writer = Poppet::Implementor::Writer.new([ # state machine
  [
    {"exists" => ["literal", true]},
    lambda do |w, actual, desired|
      w.really do
        execute( "rm", desired["path"] ) # in traditional unix style, let's remove files and symlinks but not directories.
      end
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
      w.execute( "chmod", desired["mode"], desired["path"] )
      actual.merge( "mode" => mod )
    end
  ],

  [
    { "exists" => ["literal", true], "owner" => "string" },
    lambda do |w, actual, desired|
      w.execute( "chown", desired["owner"], desired["path"] )
      actual.merge( "owner" => desired["owner"] )
    end
  ],

  [
    { "exists" => ["literal", true], "group" => "string" },
    lambda do |w, actual, desired|
      w.execute( "chown", desired["group"], desired["path"] )
      actual.merge( "group" => desired["group"] )
    end
  ]
])

require 'pp'
pp Poppet::Implementor::Solver.new( reader, desired, checker, writer ).do( command )
