self = exports ? this

counter = 0

self.onmessage = (event) ->
  console.log "in self.onmessage with event: #{event.data}"
  counter = event.data ? 0
  sendMessage() # emulate slow work here...

sendMessage = => # => means correct this context
  postMessage "some cool and very slow data: #{counter++}"
  setTimeout "sendMessage()", counter