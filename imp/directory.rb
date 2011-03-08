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

class DirReader < Poppet::Implementor::Reader
  readers :path, :exists, :mode, :owner, :group

  include Poppet::Execute::EscapeWithLittleE

  def path
    desired["path"]
  end

  def exists
    Poppet::Execute.execute_test( "test -d #{ e path } " )
  end

  def mode
    if exists
      Poppet::Execute.execute( "stat -c %a #{ e path }" ).chomp
    end
  end

  def owner
    if exists
      Poppet::Execute.execute( "stat -c %U #{ e path }" ).chomp
    end
  end

  def group
    if exists
      Poppet::Execute.execute( "stat -c %G #{ e path }" ).chomp
    end
  end
end
reader = DirReader.new(desired)

class DirChecker < Poppet::Implementor::Checker
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

  checkers :path, :exists, :mode, :owner, :group

  def owner(actual_value, desired_value)
    if ! actual_value.nil?
      numeric_user( desired_value ) == numeric_user( actual_value )
    end
  end

  def group(actual_value, desired_value)
    if ! actual_value.nil?
      numeric_group( desired_value ) == numeric_group( actual_value )
    end
  end

  def mode(actual_value, desired_value)
    simulated_chmod( actual_value, desired_value ) == actual_value
  end
end
checker = DirChecker.new

class DirWriter < Poppet::Implementor::Writer
  def mkdir( desired )
    #TODO: sudo
    #TODO: umode
    execute( "mkdir -p #{ e desired["path"] }" )
  end

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

  actions :delete, :create, :chmod, :chown, :chgrp

  def delete
    if actual["exists"]
      execute( "rmdir #{ e desired["path"] }" ) # in traditional unix style, let's only remove empty dirs
      actual.merge({
        "path" => desired["path"],
        "exists" => false
      })
    end
  end

  def create
    if ! actual["exists"]
      mkdir( desired )
      actual.merge({
        "exists"  => true,
        "path"    => desired["path"],
        #"mode"    => desired["mode"], # Not implemented yet
        #"owner"   => desired["owner"], # Not implemented yet
      })
    end
  end

  def chmod
    if actual["exists"]
      mod = simulated_chmod( actual["mode"], desired["mode"] )
      execute( "chmod #{e desired["mode"] } #{ e desired["path"] }" )
      actual.merge( "mode" => mod )
    end
  end

  def chown
    if actual["exists"]
      execute( "chown #{e desired["owner"] }, #{e desired["path"] } " )
      actual.merge( "owner" => desired["owner"] )
    end
  end

  def chgrp
    if actual["exists"]
      execute( "chgrp #{e desired["group"]} #{e desired["path"]} " )
      actual.merge( "group" => desired["group"] )
    end
  end
end
writer = DirWriter.new( desired )

puts Poppet::Implementor::Solver.new( desired, reader, checker, writer ).do( command ).to_json
