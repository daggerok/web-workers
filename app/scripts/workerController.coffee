worker = null
disabled = null

startWorker = ->
  insert 'starting worker...' unless disabled?

  disabled = typeof(Worker) is 'undefined'
  if disabled
    insert "your browser aren't supported web workers"
    return

  worker = new Worker 'worker.js' if worker is null
  worker.onmessage = (event) ->
    insert "received input message: #{event.data}"
  # initiate worker using pseudo random initial interval
  worker.postMessage "#{Math.floor(Math.random() * 1234) + 1}"

stopWorker = ->
  unless disabled
    console.log 'stopping worker...'

    # shutting down worker
    worker?.terminate()
    worker = null
    disabled = true

    insert 'worker terminated'

insert = (content) ->
  $ '#content'
      .prepend "#{content}<br/>"