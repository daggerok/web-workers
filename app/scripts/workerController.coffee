worker = null
disabled = true

startWorker = ->
  console.log 'starting worker...'

  disabled = typeof(Worker) is 'undefined'
  insert "your browser aren't supported web workers" if disabled

  worker = new Worker './worker.js' if worker is null
  
  worker.onmessage = (event) ->
    text = "called back by the worker: #{event.data}"
    insert text

  worker.postMessage "#{Math.floor(Math.random() * 5 * 333) + 1}" # using pseudo random interval

stopWorker = ->
  unless disabled
    console.log 'stopping worker...'

    worker?.terminate()
    worker = null
    disabled = true

    insert 'worker terminated'

insert = (content) ->
  $ '#content'
      .prepend "#{content}<br/>"