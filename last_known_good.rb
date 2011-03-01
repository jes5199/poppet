require 'lib/http'
require 'lib/storage'
require 'lib/settings'

settings = Poppet::Settings.new

url = ARGV[0] #TODO: validate command lines
filename = url.sub('http://', '')
filename = File.join(settings['last_known_good'], filename )
Poppet::Storage.make_dir_for( filename )
content = nil
begin
  content = Poppet::HTTP.get( url )
  print content
rescue => e
  STDERR.puts e
end
if content
  File.open( filename, "w" ) {|f| f.print content }
else
  puts File.read( filename )
end
