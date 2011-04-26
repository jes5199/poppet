require 'lib/execute'

module Poppet
  class Encryptor
    def initialize(options)
      @key = options["key"] # "0x90605AF0"
      @passphrase = options["passphrase"]

      keyring = options["keyring"] # "local"
      @private_keyring = "keys/#{keyring}.sec"
      @public_keyring  = "keys/#{keyring}.pub"
    end

    def command( extra )
      "gpg -u #{@key} --passphrase #{@passphrase} --secret-keyring #{@private_keyring} --keyring #{@public_keyring} --yes #{extra} -"
    end

    def encrypt( to, data )
      command "-aes -r #{to}"
    end

    def sign( data )
      command "--clearsign"
    end

    def decrypt( data )
      command "--decrypt"
    end
  end
end
