# Cribbed from https://github.com/ruby/base64/blob/master/lib/base64.rb
#
# Copyright (C) 1993-2013 Yukihiro Matsumoto. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#
# Removed docstrings to reduce bloat for web builds

module Base64
  # The version of this module.
  VERSION = "0.3.0"

  module_function

  def encode64(bin)
    [bin].pack("m")
  end

  def decode64(str)
    str.unpack1("m")
  end

  def strict_encode64(bin)
    [bin].pack("m0")
  end

  def strict_decode64(str)
    str.unpack1("m0")
  end

  def urlsafe_encode64(bin, padding: true)
    str = strict_encode64(bin)
    str.chomp!("==") or str.chomp!("=") unless padding
    str.tr!("+/", "-_")
    str
  end

  def urlsafe_decode64(str)
    if !str.end_with?("=") && str.length % 4 != 0
      str = str.ljust((str.length + 3) & ~3, "=")
      str.tr!("-_", "+/")
    else
      str = str.tr("-_", "+/")
    end
    strict_decode64(str)
  end
end
