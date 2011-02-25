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

if ! desired["path"]
  raise "Sorry, I don't support finding a directory without a path."
end

# Find the file
reader = Poppet::Implementor::Reader.new({
  "path" => lambda { desired["path"] },

  "exists" => lambda { Poppet::Execute.execute_test( "test -d #{ e desired["path"] } " ) },

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

  "owner"    => lambda{ |actual_value, desired_value| !actual_value.nil? and numeric_user(  desired_value ) == numeric_user(  actual_value ) },
  "group"    => lambda{ |actual_value, desired_value| !actual_value.nil? and numeric_group( desired_value ) == numeric_group( actual_value ) },

  "mode"     => lambda do |actual_value, desired_value|
                 simulated_chmod( actual_value, desired_value ) == actual_value
                end,
})

def mkdir( w, desired )
  #TODO: sudo
  #TODO: umode
  w.execute( "mkdir -p #{ e desired["path"] }" )
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
      mkdir( w, desired )
      actual.merge({
        "exists"  => true,
        "path"    => desired["path"],
        #"mode"    => desired["mode"], # Not implemented yet
        #"owner"   => desired["owner"], # Not implemented yet
      })
    end
  ],

  "chmod" => [
    { "exists" => ["literal", true] },
    lambda do |w, actual, desired|
      mod = simulated_chmod( actual["mode"], desired["mode"] )
      w.execute( "chmod #{e desired["mode"] } #{ e desired["path"] }" )
      actual.merge( "mode" => mod )
    end
  ],

  "chown" => [
    { "exists" => ["literal", true] },
    lambda do |w, actual, desired|
      w.execute( "chown #{e desired["owner"] }, #{e desired["path"] } " )
      actual.merge( "owner" => desired["owner"] )
    end
  ],

  "chgrp" => [
    { "exists" => ["literal", true] },
    lambda do |w, actual, desired|
      w.execute( "chgrp #{e desired["group"]} #{e desired["path"]} " )
      actual.merge( "group" => desired["group"] )
    end
  ]
})

require 'pp'
pp Poppet::Implementor::Solver.new( desired, reader, checker, writer ).do( command )
# TODO: print out json
