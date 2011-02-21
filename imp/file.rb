require 'rubygems'
require 'json'

require 'lib/resource'

command, desired_json = JSON.parse( STDIN.read )
desired = Poppet::Resource.new( desired_json )

# Question: should we support finding files by things other than path?
if ! desired["path"]
  raise "Sorry, I don't support finding a file without a path."
end

# TODO Find the file

# TODO For "check", return if it matches desired

# TODO For "survey", return what was on disk (for specified attrs)

def write_file( path, content )
  #TODO: sudo
  #TODO: umode
  execute( "echo", content, :output => path )
  set( "content", content )
end

# state machine
change( {"exists" => literal(true) }, {"exists" => literal(false) } ) do
  # in traditional unix style, let's remove files and symlinks but not directories.
  execute( "rm", desired["path"] )
end

change( {"exists" => literal(false) }, {"exists" => literal(true) } ) do
  write_file( "echo", desired["content"], desired["path"] )
end

within( {"exists" => literal(true)} ) do
  change( { "content" => string } , { "content" => string } ) do
    write_file( "echo", desired["content"], desired["path"] )
  end

  change( { "mode" => string }, { "mode" => string } ) do
    execute( "chmod", desired["mode"], desired["path"])
  end

  change( { "user" => either(string, integer) }, { "user" => either(string, integer) } ) do
    execute( "chown", desired["user"], desired["path"])
  end
end
