#!/usr/bin/ruby
require 'lib/implementor/dsl'
implementor do |desired|
  if ! desired["name"]
    raise "A package must be identified by name"
  end

  self.reader_class = class PackageReader < Poppet::Implementor::Reader
    readers :name, :versions, :status, :package_type

    def name
      desired["name"]
    end

    def package_type
      "gem"
    end

    def local_package
      @local_package ||= ( x( "gem list --local  #{e Regexp.escape(name)}" ).split(/\n/) rescue [] )
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

    self
  end

  self.checker_class = class PackageChecker < Poppet::Implementor::Checker
    checkers :name, :versions, :status, :package_type

    def versions(actual_value, desired_value)
      desired_value.all? do |des|
        actual_value.include?(des)
      end
    end

    self
  end

  self.writer_class = class PackageWriter < Poppet::Implementor::Writer
    actions :install, :nudge, :remove

    def gem(args)
      x( "gem #{args}" )
    end

    def gem_install(packages)
      gem( "install -y #{packages}" )
    end

    def install( extra_args = nil )
      versions = ( desired["vesions"] || [] )

      versions.each do |version|
        if version == "latest" or !version
          version = ">= 0"
        end
        gem_install( "#{e desired["name"]} --version #{e version} #{extra_args}" )
      end
      actual.merge({
        "status"   => "installed",
        "versions" => versions # TODO: actually resolve "latest" ?
      })
    end

    def nudge
      install
    end

    def remove
      gem( "uninstall -a #{ e desired["name"] }" )

      actual.merge({
        "status"   => "absent",
        "versions" => nil
      })
    end

    self
  end
end
