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
system = Poppet::Implementor::Reader.new({
  "path" => {
    "read" => lambda { desired["path"] }
  },

  "exists" => {
    "read" => lambda { execute_test( "test", "-e", desired["path"] ) },

    "within" => { [ "literal", true ] => {

      "mode" => {
        "read" => lambda { execute( "stat -c %a", desired["path"] ) }
      },

      "owner" => {
        "read" => lambda { execute( "stat -c %U", desired["path"] ) }
      },

      "group" => {
        "read" => lambda { execute( "stat -c %G", desired["path"] ) }
      },

      "content" => {
        "read" => lambda { execute( "cat", desired["path"] ) }
      },

      "checksum" => {
        "read" => lambda { execute( "md5sum", desired["path"] ).sub(/\s.*/m, "") }
      }

    } }
  }
})

def write_file( path, content )
  #TODO: sudo
  #TODO: umode
  execute( "echo", content, :output => path )
  set( "content", content )
end

writer = Poppet::Implementor::Writer.new([ # state machine
  [
    {"exists" => ["literal", true ] },
    lambda do |w, actual, desired|
      w.really do
        execute( "rm", desired["path"] ) # in traditional unix style, let's remove files and symlinks but not directories.
      end
      { "exists" => false }
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
      w.really do
        execute( "chmod", desired["mode"], desired["path"] )
      end
      { "mode"    => simulated_chmod( actual["mode"], desired["mode"] ) }
    end
  ],

  [
    { "exists" => ["literal", true], "owner" => "string" },
    lambda do |w, actual, desired|
      return {} if numeric_user( desired["owner"] ) == numeric_user( actual["owner"] )
      w.really do
        execute( "chown", desired["owner"], desired["path"] )
      end
      { "owner" => desired["owner"] }
    end
  ],

  [
    { "exists" => ["literal", true], "group" => "string" },
    lambda do |w, actual, desired|
      return {} if numeric_group( desired["group"] ) == numeric_group( actual["group"] )
      w.really do
        execute( "chown", desired["group"], desired["path"] )
      end
      { "group" => desired["group"] }
    end
  ]
])

writer.send()
# TODO For "check", return if it matches desired
# TODO For "survey", return what was on disk (for specified attrs)

