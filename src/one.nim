import parseOpt, os, strutils, asyncnet, asyncdispatch, strformat
from core/parseoptions import parseargs
from network/node import newNode, serve, connectPeers, close
from config/config import loadConfig
import core/log
import wallet/privateKey

const HELP = """
One - Simple Blockchain written by Nim lang

Usage:
  one [options]

Options:
  ---help, -h                   Show help
  --port-tcp=[PORT] , -t=[PORT] Specify TCP port
  --port-rest=[PORT], -r=[PORT] Specify REST port

Example:
  one -h
  one --port-tcp=10300 --port-rest=10301
"""

proc main() =
  # let config = loadConfig()
  let argsObj = commandLineParams().join(" ").parseargs
  if argsObj.help:
    echo HELP
    return

  if argsObj.portTcp == 0:
    error "TCP port doesn't specified"
    return

  if argsObj.portRest == 0:
    error "REST port doesn't specified"
    return

  let node = newNode(argsObj)
  # run TCP server
  asyncCheck node.serve()
  # connect to each nodes
  asyncCheck node.connectPeers()

  let keyPair = privateKey.newKeyPair("hogehoge")
  info fmt"private key: {keyPair.seckey}"
  info fmt"public key: {keyPair.pubkey}"
  info fmt"address: {keyPair.pubkey.base58Encode}"

  runForever()

  node.close()

main()
