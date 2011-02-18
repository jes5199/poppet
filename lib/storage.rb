require 'rubygems'
require 'json'
require 'fileutils'
require 'lib/timestamp'
require 'lib/execute'
require 'lib/struct'

module Poppet
  module Storage
    def self.file(name, &blk)
      FileUtils.mkdir_p( File.dirname(name) )
      File.open(name, 'w', &blk)
    end

    def self.timestamp_file(dir, &blk)
      self.file(File.join(dir, 'by_time', Poppet::Timestamp.now), &blk)
    end

    def self.map_files( glob, filter, target_dir )
      Dir.glob( glob ) do |input_filename|
        output_filename = File.join( target_dir, File.basename( input_filename ) )
        FileUtils.mkdir_p( File.dirname(output_filename) )
        Poppet::Execute.execute( "#{filter} < #{input_filename.inspect} > #{output_filename.inspect}" )
      end
    end

    def self.name_by( glob, struct_keys, target_dir )
      Dir.glob( glob ).sort.each do |input_filename|
        data = JSON.parse( File.read( input_filename ) )
        name = Poppet::Struct.by_keys(data, struct_keys)
        output_filename = File.join( target_dir, name )

        if File.symlink?(output_filename)
          current_dest = File.readlink(output_filename)
          next if current_dest == input_filename
          File.delete(output_filename)
        end
        File.symlink(input_filename, output_filename)
      end
    end

  end
end
