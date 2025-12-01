# Cribbed from https://github.com/ruby/base64/blob/master/test/base64/test_base64.rb
# See ../lib/base64.rb for additional information and license
# Modified to use DragonRuby test methods, and added specific Purple Token test

def assert_raise(assert, exception)
  yield
rescue => e
  assert.true!(e.is_a?(exception))
end

def test_sample(_args, assert)
  assert.equal!("U2VuZCByZWluZm9yY2VtZW50cw==\n", Base64.encode64('Send reinforcements'))
  assert.equal!('Send reinforcements', Base64.decode64("U2VuZCByZWluZm9yY2VtZW50cw==\n"))
  assert.equal!(
    "Tm93IGlzIHRoZSB0aW1lIGZvciBhbGwgZ29vZCBjb2RlcnMKdG8gbGVhcm4g\nUnVieQ==\n",
    Base64.encode64("Now is the time for all good coders\nto learn Ruby"))
  assert.equal!(
    "Now is the time for all good coders\nto learn Ruby",
    Base64.decode64("Tm93IGlzIHRoZSB0aW1lIGZvciBhbGwgZ29vZCBjb2RlcnMKdG8gbGVhcm4g\nUnVieQ==\n"))
  assert.equal!(
    "VGhpcyBpcyBsaW5lIG9uZQpUaGlzIGlzIGxpbmUgdHdvClRoaXMgaXMgbGlu\nZSB0aHJlZQpBbmQgc28gb24uLi4K\n",
    Base64.encode64("This is line one\nThis is line two\nThis is line three\nAnd so on...\n"))
  assert.equal!(
    "This is line one\nThis is line two\nThis is line three\nAnd so on...\n",
    Base64.decode64("VGhpcyBpcyBsaW5lIG9uZQpUaGlzIGlzIGxpbmUgdHdvClRoaXMgaXMgbGluZSB0aHJlZQpBbmQgc28gb24uLi4K"))
end

def test_encode64(_args, assert)
  assert.equal!("", Base64.encode64(""))
  assert.equal!("AA==\n", Base64.encode64("\0"))
  assert.equal!("AAA=\n", Base64.encode64("\0\0"))
  assert.equal!("AAAA\n", Base64.encode64("\0\0\0"))
  assert.equal!("/w==\n", Base64.encode64("\377"))
  assert.equal!("//8=\n", Base64.encode64("\377\377"))
  assert.equal!("////\n", Base64.encode64("\377\377\377"))
  assert.equal!("/+8=\n", Base64.encode64("\xff\xef"))
end

def test_decode64(_args, assert)
  assert.equal!("", Base64.decode64(""))
  assert.equal!("\0", Base64.decode64("AA==\n"))
  assert.equal!("\0\0", Base64.decode64("AAA=\n"))
  assert.equal!("\0\0\0", Base64.decode64("AAAA\n"))
  assert.equal!("\377", Base64.decode64("/w==\n"))
  assert.equal!("\377\377", Base64.decode64("//8=\n"))
  assert.equal!("\377\377\377", Base64.decode64("////\n"))
  assert.equal!("\xff\xef", Base64.decode64("/+8=\n"))
end

def test_strict_encode64(_args, assert)
  assert.equal!("", Base64.strict_encode64(""))
  assert.equal!("AA==", Base64.strict_encode64("\0"))
  assert.equal!("AAA=", Base64.strict_encode64("\0\0"))
  assert.equal!("AAAA", Base64.strict_encode64("\0\0\0"))
  assert.equal!("/w==", Base64.strict_encode64("\377"))
  assert.equal!("//8=", Base64.strict_encode64("\377\377"))
  assert.equal!("////", Base64.strict_encode64("\377\377\377"))
  assert.equal!("/+8=", Base64.strict_encode64("\xff\xef"))
end

def test_strict_decode64(_args, assert)
  assert.equal!("", Base64.strict_decode64(""))
  assert.equal!("\0", Base64.strict_decode64("AA=="))
  assert.equal!("\0\0", Base64.strict_decode64("AAA="))
  assert.equal!("\0\0\0", Base64.strict_decode64("AAAA"))
  assert.equal!("\377", Base64.strict_decode64("/w=="))
  assert.equal!("\377\377", Base64.strict_decode64("//8="))
  assert.equal!("\377\377\377", Base64.strict_decode64("////"))
  assert.equal!("\xff\xef", Base64.strict_decode64("/+8="))

  assert_raise(assert, ArgumentError) { Base64.strict_decode64("^") }
  assert_raise(assert, ArgumentError) { Base64.strict_decode64("A") }
  assert_raise(assert, ArgumentError) { Base64.strict_decode64("A^") }
  assert_raise(assert, ArgumentError) { Base64.strict_decode64("AA") }
  assert_raise(assert, ArgumentError) { Base64.strict_decode64("AA=") }
  assert_raise(assert, ArgumentError) { Base64.strict_decode64("AA===") }
  assert_raise(assert, ArgumentError) { Base64.strict_decode64("AA=x") }
  assert_raise(assert, ArgumentError) { Base64.strict_decode64("AAA") }
  assert_raise(assert, ArgumentError) { Base64.strict_decode64("AAA^") }
  assert_raise(assert, ArgumentError) { Base64.strict_decode64("AB==") }
  assert_raise(assert, ArgumentError) { Base64.strict_decode64("AAB=") }
end

def test_urlsafe_encode64(_args, assert)
  assert.equal!("", Base64.urlsafe_encode64(""))
  assert.equal!("AA==", Base64.urlsafe_encode64("\0"))
  assert.equal!("AAA=", Base64.urlsafe_encode64("\0\0"))
  assert.equal!("AAAA", Base64.urlsafe_encode64("\0\0\0"))
  assert.equal!("_w==", Base64.urlsafe_encode64("\377"))
  assert.equal!("__8=", Base64.urlsafe_encode64("\377\377"))
  assert.equal!("____", Base64.urlsafe_encode64("\377\377\377"))
  assert.equal!("_-8=", Base64.urlsafe_encode64("\xff\xef"))
end

def test_urlsafe_encode64_unpadded(_args, assert)
  assert.equal!("", Base64.urlsafe_encode64("", padding: false))
  assert.equal!("AA", Base64.urlsafe_encode64("\0", padding: false))
  assert.equal!("AAA", Base64.urlsafe_encode64("\0\0", padding: false))
  assert.equal!("AAAA", Base64.urlsafe_encode64("\0\0\0", padding: false))
end

def test_urlsafe_decode64(_args, assert)
  assert.equal!("", Base64.urlsafe_decode64(""))
  assert.equal!("\0", Base64.urlsafe_decode64("AA=="))
  assert.equal!("\0\0", Base64.urlsafe_decode64("AAA="))
  assert.equal!("\0\0\0", Base64.urlsafe_decode64("AAAA"))
  assert.equal!("\377", Base64.urlsafe_decode64("_w=="))
  assert.equal!("\377\377", Base64.urlsafe_decode64("__8="))
  assert.equal!("\377\377\377", Base64.urlsafe_decode64("____"))
  assert.equal!("\xff\xef", Base64.urlsafe_decode64("_+8="))
end

def test_urlsafe_decode64_unpadded(_args, assert)
  assert.equal!("\0", Base64.urlsafe_decode64("AA"))
  assert.equal!("\0\0", Base64.urlsafe_decode64("AAA"))
  assert.equal!("\0\0\0", Base64.urlsafe_decode64("AAAA"))
  assert_raise(assert, ArgumentError) { Base64.urlsafe_decode64("AA=") }
end

def test_base64_encode_purpletoken_example(_args, assert)
  # From v3api.txt - the params string that needs to be encoded (URL-safe, no padding)
  # Note: The example in the docs appears to have "gamkey" not "gamekey" based on the Base64
  input = "gamekey=c5f4a0474223a4cc0c93d68a7c80cc541d05b90c&format=json&array=yes&dates=yes&ids=yes"
  expected = "Z2FtZWtleT1jNWY0YTA0NzQyMjNhNGNjMGM5M2Q2OGE3YzgwY2M1NDFkMDViOTBjJmZvcm1hdD1qc29uJmFycmF5PXllcyZkYXRlcz15ZXMmaWRzPXllcw=="
  assert.equal! Base64.urlsafe_encode64(input), expected
end
