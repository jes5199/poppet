# TODO: settingsify
# TODO: gather key ID
Kernel.open("| gpg -u 0x90605AF0 -d --passphrase poppet --secret-keyring keys/local.sec --keyring keys/local.pub --yes -", 'w') do |gpg|
  STDIN.each do |line|
    gpg.print line
  end
end

