require 'fileutils'
require 'lib/timestamp'
require 'lib/execute'

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
      Dir.glob( File.join( glob ) ) do |input_filename|
        output_filename = File.join( target_dir, File.basename( input_filename ) )
        Poppet::Execute.execute( "#{filter} < #{input_filename} > #{output_filename}" )
      end
    end

  end
end
