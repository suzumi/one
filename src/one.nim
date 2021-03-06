import parseOpt, os, strutils, asyncnet, asyncdispatch, strformat
from core/parseoptions import parseargs
from network/node import newNode, serve, connectPeers, close
from config/config import loadConfig
import core/log
import wallet/privateKey
import wallet/account

const HELP = """
One - Simple Blockchain written by Nim lang

Usage:
  one [options]

Options:
  ---help, -h                   Show help
  --port-tcp=[PORT] , -t=[PORT] Specify TCP port
  --port-rest=[PORT], -r=[PORT] Specify REST port
  --wallet-create=[pass phrase] Create wallet, input your pass phrase

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

  if argsObj.wallet.passPhrase != "":
    discard account.newAccount(argsObj.wallet.passPhrase)

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

  runForever()

  node.close()

main()
