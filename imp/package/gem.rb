#!/usr/bin/ruby

require 'lib/implementor/helpers'
class Gem
  include Poppet::Implementor::Helpers

  def initialize(params)
    @params = params
    if ! params["name"]
      raise "A package must be identified by name"
    end
  end

  def name
    @params["name"]
  end

  def nudge?
    @params["nudge"]
  end

  def package_type
    "gem"
  end

  def local_package
    safe {
      @local_package ||= ( x( "gem list --local  #{e Regexp.escape(name)}" ).split(/\n/) rescue [] )
    }
  end

  def versions
    local_package.last =~ /\((.*)\)/
    $1.split(", ")
  end

  def status
    if versions.length > 0
      "installed"
    else
      "absent"
    end
  end

  def installed?
    "installed" == status
  end

  def should_be_installed?
    @params["status"] == "installed"
  end

  def needs_to_be_installed?
    !installed? and should_be_installed?
  end

  def needs_to_be_uninstalled?
    !should_be_installed? && installed?
  end

  def needs_different_version?
    safe {
      @params["versions"].any? do |desired_version|
        ! xt("gem list --local -i #{e Regexp.escape(name)} -v #{e desired_version}")
      end
    }
  end

  def install!
    versions = ( desired["vesions"] || ["latest"] )

    versions.each do |version|
      if version == "latest"
        version = ">= 0"
      end
      x( "gem install -y #{e desired["name"]} --version #{e version}" )
    end
  end

  def uninstall!
    x( "gem uninstall -x -a #{ e desired["name"] }" )
  end

  def run!
    case
    when needs_to_be_installed? then install!
    when needs_to_be_uninstalled? then uninstall!
    when needs_different_version? then install!
    when nudge? && installed? then install!
    end
  end
end

if __FILE__ == $0
  require 'lib/implementor/runner'
  Poppet::Implementor::Runner.run( Gem, [:name, :package_type, :status, :versions] )
end
