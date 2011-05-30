#!/usr/bin/ruby

require 'lib/implementor/helpers'
class Directory
  include Poppet::Implementor::Helpers

  def initialize( params )
    @params = params

    if ! @params["path"]
      raise "Sorry, I don't support finding a directory without a path."
    end
  end

  def path
    @params["path"]
  end

  def exists
    safe {
      Poppet::Execute.execute_test( "test -d #{ e path } " )
    }
  end

  def mode
    safe {
      if exists
        Poppet::Execute.execute( "stat -c %a #{ e path }" ).chomp
      end
    }
  end

  def owner
    safe {
      if exists
        Poppet::Execute.execute( "stat -c %U #{ e path }" ).chomp
      end
    }
  end

  def group
    safe {
      if exists
        Poppet::Execute.execute( "stat -c %G #{ e path }" ).chomp
      end
    }
  end

  # TODO extract these to lib
  def simulated_chmod( old, new)
    new #TODO: smart chmods
  end

  def numeric_user( user )
    return nil unless user
    safe {
      Poppet::Execute.execute( "id -u #{e user}" )
    }
  end

  def numeric_group( grp )
    return nil unless grp
    safe {
      Poppet::Execute.execute( "getent group #{e grp} | cut -d: -f3" ) # surprisingly ugly!
    }
  end

  def has_correct_owner?
    return true unless @params["owner"]
    numeric_user( @params["owner"] ) == numeric_user( owner )
  end

  def has_correct_group?
    return true unless @params["group"]
    numeric_group( @params["group"] ) == numeric_group( group )
  end

  def has_correct_mode?
    return true unless @params["mode"]
    simulated_chmod( mode, @params["mode"] ) == mode
  end

  def create!
    #TODO: sudo
    #TODO: umode
    execute( "mkdir -p #{ e path }" )
  end

  def delete!
    execute( "rmdir #{ e path }" ) # in traditional unix style, let's only remove empty dirs
  end

  def chmod!
    execute( "chmod #{e @params["mode"] } #{ e path }" )
  end

  def chown!
    execute( "chown #{e desired["owner"] } #{e path } " )
  end

  def chgrp!
    execute( "chgrp #{e desired["group"]} #{e path} " )
  end

  def should_exist?
    @params["exists"]
  end

  def run!
    case
    when !exists && should_exist?
      create!
    when exists && !should_exist?
      delete!
    end

    if exists
      chown! if !has_correct_owner?
      chgrp! if !has_correct_group?
      chmod! if !has_correct_mode?
    end
  end
end

if __FILE__ == $0
  require 'lib/implementor/runner'
  Poppet::Implementor::Runner.run( Directory, [:path, :exists, :mode, :owner, :group] )
end
