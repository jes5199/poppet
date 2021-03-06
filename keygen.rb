require 'lib/execute'
require 'lib/settings'

settings = Poppet::Settings.new

batch_file = settings["keys"] + "/batch.txt"
passphrase = settings["passphrase"]
key_name   = settings["key_name"]

pubkey      = "keys/#{key_name}.pub"
private_key = "keys/#{key_name}.sec"

raise "stop!" if File.exist?(pubkey) or File.exist?(private_key)

name = ARGV[0] #TODO: argument parsing

# TODO: move into lib/encrypt.rb
File.open(batch_file, "w") do |f|
  f.puts <<-BATCH
     %echo Generating a standard key
     Key-Type: RSA
     Key-Length: 1024
     Name-Real: #{name}
     Name-Comment: Poppet
     Name-Email: poppet
     Expire-Date: 0
     Passphrase: #{passphrase}
     %pubring #{pubkey}
     %secring #{private_key}
     # Do a commit here, so that we can later print "done" :-)
     %commit
     %echo done
  BATCH
end

entropy_maker = "ls -R /"

Poppet::Execute.execute("#{entropy_maker} 2> /dev/null > /dev/null &")
puts Poppet::Execute.execute("gpg --batch --gen-key #{batch_file}/batch.txt")

