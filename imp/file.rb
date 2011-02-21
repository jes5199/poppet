require 'rubygems'
require 'json'

require 'lib/resource'
require 'lib/implementor/reader'

command, desired_json = JSON.parse( STDIN.read )
desired = Poppet::Resource.new( desired_json )

# Question: should we support finding files by things other than path?
if ! desired["path"]
  raise "Sorry, I don't support finding a file without a path."
end

def execute_test(*args)
  false # FIXME
end
def execute(*args)
  `#{args.join(" ")}` # FIXME
end

# Find the file
reader = Poppet::Implementor::Reader.new({
  "path" => lambda { desired["path"] },

  "exists" => lambda { execute_test( "test", "-e", desired["path"] ) },

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
    lambda { execute( "cat", desired["path"] ) }
  ],

  "checksum" => [
    { "exists" => [ "literal", true ] },
    lambda { execute( "md5sum", desired["path"] ).sub(/\s.*/m, "") }
  ]
})

def write_file( path, content )
  #TODO: sudo
  #TODO: umode
  execute( "echo", content, :output => path )
  set( "content", content )
end

checker = Poppet::Implementor::Checker.new({
  "path"     => lambda{ |actual, desired| actual == desired },
  "exists"   => lambda{ |actual, desired| actual == desired },
  "content"  => lambda{ |actual, desired| actual == desired },
  "mode"     => lambda do |actual, desired|
                 simulated_chmod( actual["mode"], desired["mode"] ) == actual["mode"]
                end,
  "owner"    => lambda{ |actual, desired| numeric_user(  desired["owner"] ) == numeric_user(  actual["owner"] ) },
  "group"    => lambda{ |actual, desired| numeric_group( desired["owner"] ) == numeric_group( actual["owner"] ) },
  "checksum" => lambda{ |actual, desired| actual == desired },
})

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
      w.really do
        write_file( desired )
      end
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
      w.really do
        write_file( "echo", desired["content"], desired["path"] )
      end
      { "content" => desired["content"] }
    end
  ],

  [
    { "exists" => ["literal", true], "mode" => "string" },
    lambda do |w, actual, desired|
      mod = simulated_chmod( actual["mode"], desired["mode"] )
      w.really do
        execute( "chmod", desired["mode"], desired["path"] )
      end
      actual.merge( "mode"    => mod )
    end
  ],

  [
    { "exists" => ["literal", true], "owner" => "string" },
    lambda do |w, actual, desired|
      w.really do
        execute( "chown", desired["owner"], desired["path"] )
      end
      actual.merge( "owner" => desired["owner"] )
    end
  ],

  [
    { "exists" => ["literal", true], "group" => "string" },
    lambda do |w, actual, desired|
      w.really do
        execute( "chown", desired["group"], desired["path"] )
      end
      actual.merge( "group" => desired["group"] )
    end
  ]
])

writer.send()
# TODO For "check", return if it matches desired
# TODO For "survey", return what was on disk (for specified attrs)

