import asyncnet, asyncdispatch

var clients {.threadvar.}: seq[AsyncSocket]

proc processClient(client: AsyncSocket) {.async.} =
  echo "foobar"
  while true:
    let line = await client.recvLine()
    if line.len == 0: break
    for c in clients:
      await c.send(line & "\c\L")

proc serve() {.async.} =
  clients = @[]
  var server = newAsyncSocket()
  server.setSockOpt(OptReuseAddr, true)
  server.bindAddr(Port(8888))
  server.listen()
  
  while true:
    let client = await server.accept()
    echo "hogehoge"
    clients.add client
    
    asyncCheck processClient(client)

asyncCheck serve()
runForever()