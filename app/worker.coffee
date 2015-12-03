self = exports ? this

counter = 0

self.onmessage = (event) ->
  console.log "starting worker... initial data: #{event.data}"
  counter = event.data ? 0
  sendMessage() # emulate slow work here...

sendMessage = => # use fat arrow `=>` for this.-context
  postMessage "worker response: #{counter++}"
  setTimeout "sendMessage()", counter