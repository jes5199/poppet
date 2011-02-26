#!/usr/bin/ruby

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

  "exists" => lambda { |r| Poppet::Execute.execute_test( "test -e #{ e r["path"] } " ) },

  "mode"   => [
    { "exists" => [ "literal", true ] },
    lambda { |r| Poppet::Execute.execute( "stat -c %a #{ e r["path"] }" ).chomp }
  ],

  "owner" => [
    { "exists" => [ "literal", true ] },
    lambda { |r| Poppet::Execute.execute( "stat -c %U #{ e r["path"] }" ).chomp }
  ],

  "group" => [
    { "exists" => [ "literal", true ] },
    lambda { |r| Poppet::Execute.execute( "stat -c %G #{ e r["path"] }" ).chomp }
  ],

  "content" => [
    { "exists" => [ "literal", true ] },
    lambda { |r| Poppet::Execute.execute( "cat #{ e r["path"] }" ) }
  ],

  "checksum" => [
    { "exists" => [ "literal", true ] },
    lambda { |r| Poppet::Execute.execute( "md5sum #{ e r["path"] }" ).sub(/\s.*/m, "") }
  ]
})

# TODO extract these to lib
def simulated_chmod( old, new)
  new #TODO: smart chmods
end

def numeric_user( user )
  Poppet::Execute.execute( "id -u #{e user}" )
end

def numeric_group( grp )
  Poppet::Execute.execute( "getent group #{e grp} | cut -d: -f3" ) # surprisingly ugly!
end

checker = Poppet::Implementor::Checker.new({
  "path"     => lambda{ |actual_value, desired_value| actual_value == desired_value },
  "exists"   => lambda{ |actual_value, desired_value| actual_value == desired_value },
  "content"  => lambda{ |actual_value, desired_value| actual_value == desired_value },
  "checksum" => lambda{ |actual_value, desired_value| actual_value == desired_value },

  "owner"    => lambda{ |actual_value, desired_value| !actual_value.nil? and numeric_user(  desired_value ) == numeric_user(  actual_value ) },
  "group"    => lambda{ |actual_value, desired_value| !actual_value.nil? and numeric_group( desired_value ) == numeric_group( actual_value ) },

  "mode"     => lambda do |actual_value, desired_value|
                 simulated_chmod( actual_value, desired_value ) == actual_value
                end,
})

def write_file( w, desired )
  #TODO: sudo
  #TODO: umode
  w.execute( "echo -n #{ e desired["content"] } > #{ e desired["path"] } " )
end

writer = Poppet::Implementor::Writer.new({ # state machine
  "delete" => [
    {"exists" => ["literal", true]},
    lambda do |w, actual, desired|
      w.execute( "rm #{ e desired["path"] }" ) # in traditional unix style, let's remove files and symlinks but not directories.
      actual.merge({
        "path" => desired["path"],
        "exists" => false
      })
    end
  ],

  "create" => [
    {"exists" => ["literal", false]},
    lambda do |w, actual, desired|
      write_file( w, desired )
      actual.merge({
        "exists"  => true,
        "path"    => desired["path"],
        #"mode"    => desired["mode"], # Not implemented yet
        #"owner"   => desired["owner"], # Not implemented yet,
        "content" => desired["content"]
      })
    end
  ],

  "overwrite" => [
    { "exists" => ["literal", true] },
    lambda do |w, actual, desired|
      write_file( w, desired )
      actual.merge( "content" => desired["content"] )
    end
  ],

  "chmod" => [
    { "exists" => ["literal", true] },
    lambda do |w, actual, desired|
      return unless desired["mode"]
      mod = simulated_chmod( actual["mode"], desired["mode"] )
      w.execute( "chmod #{e desired["mode"] } #{ e desired["path"] }" )
      actual.merge( "mode" => mod )
    end
  ],

  "chown" => [
    { "exists" => ["literal", true] },
    lambda do |w, actual, desired|
      return unless desired["owner"]
      w.execute( "chown #{e desired["owner"] }, #{e desired["path"] } " )
      actual.merge( "owner" => desired["owner"] )
    end
  ],

  "chgrp" => [
    { "exists" => ["literal", true] },
    lambda do |w, actual, desired|
      return unless desired["group"]
      w.execute( "chgrp #{e desired["group"]} #{e desired["path"]} " )
      actual.merge( "group" => desired["group"] )
    end
  ]
})

puts Poppet::Implementor::Solver.new( desired, reader, checker, writer ).do( command ).to_json
