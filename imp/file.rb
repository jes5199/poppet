#!/usr/bin/ruby

require 'lib/implementor/helpers'
class Phile
  include Poppet::Implementor::Helpers

  def initialize(params)
    @params = params

    # Question: should we support finding files by things other than path?
    if ! @params["path"]
      raise "Sorry, I don't support finding a file without a path."
    end
  end

  def run!
    case
    when !exists? && should_exist?
      write_file!
    when exists? && !should_exist?
      delete!
    when exists? && !has_correct_content?
      write_file!
    end

    if exists?
      chown! unless has_correct_owner?
      chgrp! unless has_correct_group?
      chmod! unless has_correct_mode?
    end
  end


  def path
    @params["path"]
  end

  def exists?
    safe {
      x?( "test -e #{ e path } " )
    }
  end

  def mode
    if exists?
      safe {
        x( "stat -c %a #{ e path }" ).chomp
      }
    end
  end

  def owner
    if exists?
      safe {
        x( "stat -c %U #{ e path }" ).chomp
      }
    end
  end

  def group
    if exists?
      safe {
        x( "stat -c %G #{ e path }" ).chomp
      }
    end
  end

  def content
    if exists?
      safe {
        x( "cat #{ e path }" )
      }
    end
  end

  def checksum
    if exists?
      safe {
        # TODO: work with Mac's `md5`, too
        x( "md5sum #{ e path }" ).sub(/\s.*/m, "")
      }
    end
  end

  # TODO extract these to lib
  def simulated_chmod( old, new)
    new #TODO: simulate chmodding with symbolic modes
  end

  def numeric_user( user )
    return nil unless user
    safe {
      x( "id -u #{e user}" )
    }
  end

  def numeric_group( grp )
    return nil unless grp
    safe {
      x( "getent group #{e grp} | cut -d: -f3" ) # surprisingly ugly!
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

  def has_correct_content?
    return true unless @params["content"]
    content == @params["content"]
  end

  def write_file!
    #TODO: sudo
    #TODO: umode
    # TODO: use a temp file or something that doesn't have the command-line length problem
    execute( "echo -n #{ e @params["content"] } > #{ e path } " )
  end

  def delete!
    if exists?
      x( "rm #{ e path }" ) # in traditional unix style, let's remove files and symlinks but not directories.
    end
  end

  def nudge!
    x( "touch #{ e path }" )
  end

  def chmod!
    x( "chmod #{e @params["mode"] } #{ e path }" )
  end

  def chown
    x( "chown #{e @params["owner"] } #{e path } " )
  end

  def chgrp
    x( "chgrp #{e @params["group"]} #{e path } " )
  end
end

if __FILE__ == $0
  require 'lib/implementor/runner'
  Poppet::Implementor::Runner.run( Phile, [:path, :exists?, :mode, :owner, :group, :content, :checksum] )
end
