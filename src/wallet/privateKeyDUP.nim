import secp256k1 as ECDSA
import ../nimcrypto/nimcrypto/sysrand, ../nimcrypto/nimcrypto/utils
import ../core/log

const
  KeyLength* = 256 div 8 # 32bytes
  RawSignatureSize* = KeyLength * 2 + 1
  RawPublicKeySize* = KeyLength * 2

type
  PublicKey* = ECDSA.secp256k1_pubkey
    ## Representation of public key

  PrivateKey* = object
    ## Representation of secret key
    data*: array[KeyLength, byte]

  SharedSecret* = object
    ## Representation of ECDH shared secret
    data*: array[KeyLength, byte]

  KeyPair* = object
    ## Representation of private/public keys pair
    seckey*: PrivateKey
    pubkey*: PublicKey

  Signature* = ECDSA.secp256k1_ecdsa_recoverable_signature
    ## Representation of signature

  Secp256k1Exception* = object of Exception
    ## Exceptions generated by `libsecp256k1`

  KeysContext = ref object
    context: ptr secp256k1_context
    error: string


var keyContext {.threadvar.}: KeysContext

proc illegalCallback(message: cstring; data: pointer) {.cdecl.} =
  let ctx = cast[KeysContext](data)
  ctx.error = $message

proc errorCallback(message: cstring, data: pointer) {.cdecl.} =
  let ctx = cast[KeysContext](data)
  ctx.error = $message

proc newKeyContext(): KeysContext =
  let flags = cuint(SECP256K1_CONTEXT_VERIFY or SECP256K1_CONTEXT_SIGN)
  result.context = secp256k1_context_create(flags)
  secp256k1_context_set_illegal_callback(result.context, illegalCallback,
                                         cast[pointer](result))
  secp256k1_context_set_error_callback(result.context, errorCallback,
                                       cast[pointer](result))
  result.error = ""

proc getKeyContext(): ptr secp256k1_context =
  if keyContext.isNil:
    keyContext = newKeyContext()
  result = keyContext.context

  ##
  ## public
  ##

proc newPrivateKey*(): PrivateKey =
  # Generates new private key.
  let ctx = getKeyContext()
  while true:
    if randomBytes(result.data) == KeyLength:
      if secp256k1_ec_seckey_verify(ctx, cast[ptr cuchar](addr result)) == 1:
        break

proc getPublicKey*(seckey: PrivateKey): PublicKey =
  ## Return public key
  let ctx = getKeyContext()
  if secp256k1_ec_pubkey_create(ctx, addr result, cast[ptr cuchar](unsafeAddr seckey)) != 1:
    info "raiseSecp256k1Error"
    # raiseSecp256k1Error()

proc newKeyPair*(): KeyPair =
  result.seckey = newPrivateKey()
  result.pubkey = result.seckey.getPublicKey()
