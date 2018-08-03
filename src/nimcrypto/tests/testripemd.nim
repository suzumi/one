import nimcrypto/hash, nimcrypto/utils, nimcrypto/ripemd
import unittest

const vectors = [
  "",
  "a",
  "abc",
  "message digest",
  "abcdefghijklmnopqrstuvwxyz",
  "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq",
  "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789",
  """1234567890123456789012345678901234567890
     1234567890123456789012345678901234567890"""
]

const Ripemd128C = [
  "CDF26213A150DC3ECB610F18F6B38B46", "86BE7AFA339D0FC7CFC785E72F578D33",
  "C14A12199C66E4BA84636B0F69144C77", "9E327B3D6E523062AFC1132D7DF9D1B8",
  "FD2AA607F71DC8F510714922B371834E", "A1AA0689D0FAFA2DDC22E88B49133A06",
  "D1E959EB179C911FAEA4624C60C5C702", "3F45EF194732C2DBB2C4A2C769795FA3",
  "4A7F5723F954EBA1216C9D8F6320431F"
]

const RipeMD160C = [
  "9C1185A5C5E9FC54612808977EE8F548B2258D31",
  "0BDC9D2D256B3EE9DAAE347BE6F4DC835A467FFE",
  "8EB208F7E05D987A9B044A8E98C6B087F15A0BFC",
  "5D0689EF49D2FAE572B881B123A85FFA21595F36",
  "F71C27109C692C1B56BBDCEB5B9D2865B3708DBC",
  "12A053384A9C0C88E405A06C27DCF49ADA62EB2B",
  "B0E20B6E3116640286ED3A87A5713079B21F5189",
  "9B752E45573D4B39F4DBD3323CAB82BF63326BFB",
  "52783243C1697BDBE16D37F97F68F08325DC1528"
]

const RipeMD256C = [
  "02BA4C4E5F8ECD1877FC52D64D30E37A2D9774FB1E5D026380AE0168E3C5522D",
  "F9333E45D857F5D90A91BAB70A1EBA0CFB1BE4B0783C9ACFCD883A9134692925",
  "AFBD6E228B9D8CBBCEF5CA2D03E6DBA10AC0BC7DCBE4680E1E42D2E975459B65",
  "87E971759A1CE47A514D5C914C392C9018C7C46BC14465554AFCDF54A5070C0E",
  "649D3034751EA216776BF9A18ACC81BC7896118A5197968782DD1FD97D8D5133",
  "3843045583AAC6C8C8D9128573E7A9809AFB2A0F34CCC36EA9E72F16F6368E3F",
  "5740A408AC16B720B84424AE931CBB1FE363D1D0BF4017F1A89F7EA6DE77A0B8",
  "06FDCC7A409548AAF91368C06A6275B553E3F099BF0EA4EDFD6778DF89A890DD",
  "AC953744E10E31514C150D4D8D7B677342E33399788296E43AE4850CE4F97978"
]

const RipeMD320C = [
  """22D65D5661536CDC75C1FDF5C6DE7B41B9F27325
     EBC61E8557177D705A0EC880151C3A32A00899B8""",
  """CE78850638F92658A5A585097579926DDA667A57
     16562CFCF6FBE77F63542F99B04705D6970DFF5D""",
  """DE4C01B3054F8930A79D09AE738E92301E5A1708
     5BEFFDC1B8D116713E74F82FA942D64CDBC4682D""",
  """3A8E28502ED45D422F68844F9DD316E7B98533FA
     3F2A91D29F84D425C88D6B4EFF727DF66A7C0197""",
  """CABDB1810B92470A2093AA6BCE05952C28348CF4
     3FF60841975166BB40ED234004B8824463E6B009""",
  """D034A7950CF722021BA4B84DF769A5DE2060E259
     DF4C9BB4A4268C0E935BBC7470A969C9D072A1AC""",
  """ED544940C86D67F250D232C30B7B3E5770E0C60C
     8CB9A4CAFE3B11388AF9920E1B99230B843C86A4""",
  """557888AF5F6D8ED62AB66945C6D2A0A47ECD5341
     E915EB8FEA1D0524955F825DC717E4A008AB2D42""",
  """BDEE37F4371E20646B8B0D862DDA16292AE36F40
     965E8C8509E63D1DBDDECC503E2B63EB9245BB66"""
]

var ctx128, octx128: ripemd128
var ctx160, octx160: ripemd160
var ctx256, octx256: ripemd256
var ctx320, octx320: ripemd320

suite "RipeMD Tests":
  test "RIPEMD 128/160/256/320 block sizes":
    check:
      ripemd128.sizeBlock == 64
      ripemd160.sizeBlock == 64
      ripemd256.sizeBlock == 64
      ripemd320.sizeBlock == 64
      ctx128.sizeBlock == 64
      ctx160.sizeBlock == 64
      ctx256.sizeBlock == 64
      ctx320.sizeBlock == 64

  test "RIPEMD 128/160/256/320 digest sizes":
    check:
      ripemd128.sizeDigest == 16
      ripemd160.sizeDigest == 20
      ripemd256.sizeDigest == 32
      ripemd320.sizeDigest == 40
      ctx128.sizeDigest == 16
      ctx160.sizeDigest == 20
      ctx256.sizeDigest == 32
      ctx320.sizeDigest == 40

  test "RIPEMD 128/160/256/320 test vectors":
    var i = 0
    for item in vectors:
      var a = item
      if a != "message digest":
        a = stripSpaces(a)
      ctx128.init()
      ctx160.init()
      ctx256.init()
      ctx320.init()
      octx128.init()
      octx160.init()
      octx256.init()
      octx320.init()
      if len(a) == 0:
        ctx128.update(nil, 0'u)
        ctx160.update(nil, 0'u)
        ctx256.update(nil, 0'u)
        ctx320.update(nil, 0'u)
      else:
        ctx128.update(cast[ptr uint8](addr a[0]), uint(len(a)))
        ctx160.update(cast[ptr uint8](addr a[0]), uint(len(a)))
        ctx256.update(cast[ptr uint8](addr a[0]), uint(len(a)))
        ctx320.update(cast[ptr uint8](addr a[0]), uint(len(a)))
      octx128.update(a)
      octx160.update(a)
      octx256.update(a)
      octx320.update(a)
      check:
        $ctx128.finish() == stripSpaces(RipeMD128C[i])
        $ctx160.finish() == stripSpaces(RipeMD160C[i])
        $ctx256.finish() == stripSpaces(RipeMD256C[i])
        $ctx320.finish() == stripSpaces(RipeMD320C[i])
        $octx128.finish() == stripSpaces(RipeMD128C[i])
        $octx160.finish() == stripSpaces(RipeMD160C[i])
        $octx256.finish() == stripSpaces(RipeMD256C[i])
        $octx320.finish() == stripSpaces(RipeMD320C[i])
      ctx128.clear()
      ctx160.clear()
      ctx256.clear()
      ctx320.clear()
      octx128.clear()
      octx160.clear()
      octx256.clear()
      octx320.clear()
      check:
        ctx128.isFullZero() == true
        ctx160.isFullZero() == true
        ctx256.isFullZero() == true
        ctx320.isFullZero() == true
        octx128.isFullZero() == true
        octx160.isFullZero() == true
        octx256.isFullZero() == true
        octx320.isFullZero() == true
      if len(a) == 0:
        var dcheck128 = $ripemd128.digest(nil, 0'u)
        var dcheck160 = $ripemd160.digest(nil, 0'u)
        var dcheck256 = $ripemd256.digest(nil, 0'u)
        var dcheck320 = $ripemd320.digest(nil, 0'u)
        check:
          $dcheck128 == stripSpaces(RipeMD128C[i])
          $dcheck160 == stripSpaces(RipeMD160C[i])
          $dcheck256 == stripSpaces(RipeMD256C[i])
          $dcheck320 == stripSpaces(RipeMD320C[i])
      else:
        var dcheck128 = $ripemd128.digest(cast [ptr uint8](addr a[0]),
                                          uint(len(a)))
        var dcheck160 = $ripemd160.digest(cast [ptr uint8](addr a[0]),
                                          uint(len(a)))
        var dcheck256 = $ripemd256.digest(cast [ptr uint8](addr a[0]),
                                          uint(len(a)))
        var dcheck320 = $ripemd320.digest(cast [ptr uint8](addr a[0]),
                                          uint(len(a)))
        check:
          $dcheck128 == stripSpaces(RipeMD128C[i])
          $dcheck160 == stripSpaces(RipeMD160C[i])
          $dcheck256 == stripSpaces(RipeMD256C[i])
          $dcheck320 == stripSpaces(RipeMD320C[i])
          $ripemd128.digest(a) == stripSpaces(RipeMD128C[i])
          $ripemd160.digest(a) == stripSpaces(RipeMD160C[i])
          $ripemd256.digest(a) == stripSpaces(RipeMD256C[i])
          $ripemd320.digest(a) == stripSpaces(RipeMD320C[i])

      inc(i)

  test "RIPEMD 128/160/256/320 million test":
    ctx128.init()
    ctx160.init()
    ctx256.init()
    ctx320.init()
    octx128.init()
    octx160.init()
    octx256.init()
    octx320.init()
    var am = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    for i in 0..(15625 - 1):
      ctx128.update(cast[ptr uint8](addr am[0]), uint(len(am)))
      ctx160.update(cast[ptr uint8](addr am[0]), uint(len(am)))
      ctx256.update(cast[ptr uint8](addr am[0]), uint(len(am)))
      ctx320.update(cast[ptr uint8](addr am[0]), uint(len(am)))
      octx128.update(am)
      octx160.update(am)
      octx256.update(am)
      octx320.update(am)
    check:
      $ctx128.finish() == stripSpaces(Ripemd128C[8])
      $ctx160.finish() == stripSpaces(Ripemd160C[8])
      $ctx256.finish() == stripSpaces(Ripemd256C[8])
      $ctx320.finish() == stripSpaces(Ripemd320C[8])
      $octx128.finish() == stripSpaces(Ripemd128C[8])
      $octx160.finish() == stripSpaces(Ripemd160C[8])
      $octx256.finish() == stripSpaces(Ripemd256C[8])
      $octx320.finish() == stripSpaces(Ripemd320C[8])
    ctx128.clear()
    ctx160.clear()
    ctx256.clear()
    ctx320.clear()
    octx128.clear()
    octx160.clear()
    octx256.clear()
    octx320.clear()
    check:
      ctx128.isFullZero() == true
      ctx160.isFullZero() == true
      ctx256.isFullZero() == true
      ctx320.isFullZero() == true
      octx128.isFullZero() == true
      octx160.isFullZero() == true
      octx256.isFullZero() == true
      octx320.isFullZero() == true
