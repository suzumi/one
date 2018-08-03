import unittest
import nimcrypto/[hash, keccak, sha2, ripemd, blake2]

suite "Test API":

  proc hashProc(T: typedesc, input: string, output: var openArray[byte]) =
    var ctx: T
    ctx.init()
    ctx.update(cast[ptr byte](input[0].unsafeAddr), uint(input.len))
    ctx.finish(output)
    ctx.clear()

  test "Finish API":
    var y: array[32, byte]
    hashProc(keccak256, "hello", y)
    hashProc(sha256, "hello", y)
    hashProc(ripemd256, "hello", y)
    hashProc(blake2_256, "hello", y)
