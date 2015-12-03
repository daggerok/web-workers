worker = null
disabled = null

startWorker = ->
  insert "#{if disabled? then 'restarting' else 'starting'} worker..."

  return insert "your browser aren't supported web workers" if disabled = typeof(Worker) is 'undefined'

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