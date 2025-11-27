module HighScore
  # NOTE: This is obfuscation. At best, the only thing it does is ensure your key isn't in plain text in your repo.
  module BadCrypto
    extend self

    SOURCE = 'abcdef0123456789ghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ @#%^&*()\-_+=[]{}\\|;:\'",.<>/?~`!$'.freeze
    DEST   = 'plsdonthackme!?$Q\'9Z_[C#+YjNP}zUFDHi1@f=<4TR%3qv.,x"8AB{]M`*Vb6w/0r5yO:XL\- 7;gE\\&Su>|^~WKI2J)(G'.freeze

    def decrypt(str)
      str.tr(DEST, SOURCE)
    end

    def encrypt(str)
      str.tr(SOURCE, DEST)
    end
  end
end
