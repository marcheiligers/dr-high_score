module HighScore
  # NOTE: This is obfuscation. At best, the only thing it does is ensure your key isn't in plain text in your repo.
  module BadCrypto
    extend self

    SOURCE = 'abcdef0123456789'
    DEST = 'plsdonthackme!?$' # okspaceladyluvyoubyebye

    def decrypt(str)
      str.tr(DEST, SOURCE)
    end

    def encrypt(str)
      str.tr(SOURCE, DEST)
    end
  end
end
