#!/usr/bin/ruby

require 'rubygems'
require 'json'

require 'lib/resource'
require 'lib/implementor/reader'
require 'lib/implementor/checker'
require 'lib/implementor/writer'
require 'lib/implementor/solver'

include Poppet::Execute::EscapeWithLittleE

command, desired_json, *extra = JSON.parse( STDIN.read )
desired = Poppet::Resource.new( desired_json )

# Question: should we support finding files by things other than path?
if ! desired["path"]
  raise "Sorry, I don't support finding a file without a path."
end

# Find the file
class FileReader < Poppet::Implementor::Reader
  readers :path, :exists, :mode, :owner, :group, :content, :checksum

  include Poppet::Execute::EscapeWithLittleE

  def path
    desired["path"]
  end

  def exists
    Poppet::Execute.execute_test( "test -e #{ e path } " )
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

  def content
    if exists
      Poppet::Execute.execute( "cat #{ e path }" )
    end
  end

  def checksum
    if exists
       Poppet::Execute.execute( "md5sum #{ e r["path"] }" ).sub(/\s.*/m, "")
    end
  end
end

reader = FileReader.new(desired)

class FileChecker < Poppet::Implementor::Checker
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

  checkers :path, :exists, :mode, :owner, :group, :content, :checksum

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
checker = FileChecker.new

class FileWriter < Poppet::Implementor::Writer
  def write_file( desired )
    #TODO: sudo
    #TODO: umode
    execute( "echo -n #{ e desired["content"] } > #{ e desired["path"] } " )
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

  actions :delete, :create, :nudge, :overwrite, :chmod, :chown, :chgrp

  def delete
    if actual["exists"]
      execute( "rm #{ e desired["path"] }" ) # in traditional unix style, let's remove files and symlinks but not directories.
      actual.merge({
        "path"   => desired["path"],
        "exists" => false
      })
    end
  end

  def create
    if not actual["exists"]
      write_file( desired )
      actual.merge({
        "exists"  => true,
        "path"    => desired["path"],
        #"mode"    => desired["mode"], # Not implemented yet
        #"owner"   => desired["owner"], # Not implemented yet,
        "content" => desired["content"]
      })
    end
  end

  def nudge
    execute( "touch #{ e desired["path"] }" )
    actual.merge({
      "path" => desired["path"],
      "exists" => true
    })
  end

  def overwrite
    if actual["exists"]
      write_file( desired )
      actual.merge( "content" => desired["content"] )
    end
  end

  def chmod
    if actual["exists"]
      return unless desired["mode"]
      mod = simulated_chmod( actual["mode"], desired["mode"] )
      execute( "chmod #{e desired["mode"] } #{ e desired["path"] }" )
      actual.merge( "mode" => mod )
    end
  end

  def chown
    if actual["exists"]
      return unless desired["owner"]
      execute( "chown #{e desired["owner"] }, #{e desired["path"] } " )
      actual.merge( "owner" => desired["owner"] )
    end
  end

  def chgrp
    if actual["exists"]
      return unless desired["group"]
      execute( "chgrp #{e desired["group"]} #{e desired["path"]} " )
      actual.merge( "group" => desired["group"] )
    end
  end
end
writer = FileWriter.new( desired )

puts Poppet::Implementor::Solver.new( desired, reader, checker, writer ).do( command, *extra ).to_json
