#!/usr/bin/ruby

require 'lib/implementor/helpers'
class Apt
  include Poppet::Implementor::Helpers

  def initialize(params)
    @params = params

    if ! @params["name"]
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
    "deb"
  end

  def dpkg_query
    safe {
      x( "dpkg-query -s #{e name}" ).split(/\n/) rescue []
    }
  end

  def versions
    dpkg_query.grep(/^Version: (.*)/)
    [ $1.strip ]
  end

  def status
    dpkg_query.grep(/^Status: \S* \S* (\S*)/)
    case $1
    when "installed"
      "installed"
    when "config-files"
      "configured"
    when "not-installed"
      "absent"
    end
  end

  def installed?
    "installed" == status
  end

  def purged?
    "absent" == status
  end

  def should_be_installed?
    @params["status"] == "installed"
  end

  def should_be_purged?
    @params["status"] == "purged"
  end

  def needs_different_version?
    installed_versions = self.versions
    @params["versions"].any? do |desired_version|
      ! installed_versions.include?(desired_version)
    end
  end

  def needs_to_be_installed?
    !installed? and should_be_installed?
  end

  def needs_to_be_purged?
    !purged and should_be_purged?
  end

  def needs_to_be_uninstalled?
    installed? and !should_be_installed?
  end

  def apt_get(args)
    x( "export DEBIAN_FRONTEND=noninteractive ; apt-get #{args}" )
  end

  def apt_get_install(packages)
    apt_get( "install -y #{packages}" )
  end

  def install!(extra_args)
    versions = ( @params["vesions"] || [] )
    raise "apt can only install one version at a time" if versions.length > 1

    version = versions.first
    if version == "latest" or !version
      name = e @params["name"]
    else
      name = "#{e @params["name"]}=#{e version}"
    end
    apt_get_install( "#{name} #{extra_args}" )
  end

  def uninstall!
    apt_get( "remove #{ e desired["name"] }" )
  end

  def purge!
    apt_get( "purge #{ e desired["name"] }" )
  end

  def run!
    case
    when needs_to_be_installed? then install!
    when needs_to_be_purged? then purge!
    when needs_to_be_uninstalled? then uninstall!
    when needs_different_version? then install!
    when nudge? && installed? then install!("--reinstall")
    end
  end
end

if __FILE__ == $0
  require 'lib/implementor/runner'
  Poppet::Implementor::Runner.run( Apt, [:name, :package_type, :status, :versions] )
end
