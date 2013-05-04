$ ->
  return unless $('body.lessons.edit').length > 0

  lessonComposition = lesson.lesson_composition

  phrasesComposition = []
  mediaTitle = null
  for c in lesson.lesson_composition 
    for item in c
      if item.className == 'Phrases'
        phrasesComposition = [[item]]
        mediaTitle = item.mediaTitle

  lesson.lesson_composition = phrasesComposition
  Lesson.instance = new Lesson(lesson, true)

  phrases = null
  for k,v of Lesson.instance.medias
    if v.className == 'Phrases'
      phrases = v

  return unless phrases?

  container = $('#lesson-editor')

  # Show table
  data = [
    ['Index', 'Start', 'End', 'Config']
  ]

  for i, phrase of phrases.phrases
    data.push [parseInt(i)+1, phrase.start, phrase.end, JSON.stringify(phrase.config)]

  phrasesMedia = Lesson.instance.medias[mediaTitle]

  dataTable = container.find('.dataTable')
  dataTable.handsontable
    data: data
    minRows: 100
    onSelectionEnd: (r, c, r2, c2) ->
      phrasesMedia.playPhrase(r-1, true)
      if c == 2
        phrase = phrases.phrases[r-1]
        phrasesMedia.mediaElement.setCurrentTime(phrase.end - 3) if phrase
      return false
    onChange: (changes, source) ->
      return unless changes && changes.length

      # apply changes to phrases
      for change in changes
        r = change[0]-1
        if r >= 0
          phrase = phrases.phrases[r]
          continue unless phrase
          if change[1] == 1
            phrase.start = parseFloat(change[3])
          else if change[1] == 2
            phrase.end = parseFloat(change[3])

      return unless changes.length == 1
      change = changes[0]

      if change[1] == 1
        # start is changed
        phrasesMedia.playPhrase(change[0]-1, true)
      else if change[1] == 2
        # end is changed
        r = change[0] - 1
        phrase = phrases.phrases[r]
        phrasesMedia.playPhrase(r, true)
        phrasesMedia.mediaElement.setCurrentTime(phrase.end - 3) if phrase

  # New phrases creation
  phraseStarted = false
  phraseStartTime = 0
  startPhrase = ->
    unless phraseStarted
      phrasesMedia.mediaElement.pause()
      phraseStarted = true
      phraseStartTime = new Date().getTime()

  endPhrase = ->
    phraseStarted = false
    phraseLength = ((new Date().getTime()) - phraseStartTime) / 1000
    
    rowCount = dataTable.handsontable('countRows')
    emptyRowCount = dataTable.handsontable('countEmptyRows', true)

    if emptyRowCount
      rowIndex = rowCount - emptyRowCount
    else
      dataTable.handsontable('alter','insert_row')
      rowIndex = rowCount

    dataTable.handsontable('setDataAtCell', rowIndex, 0, rowIndex)
    dataTable.handsontable('setDataAtCell', rowIndex, 1, (phrasesMedia.mediaElement.currentTime - phraseLength))
    dataTable.handsontable('setDataAtCell', rowIndex, 2, phrasesMedia.mediaElement.currentTime)
    phrasesMedia.mediaElement.play()

  $(document).bind "keydown", "T", ->
    startPhrase()

  $(document).bind "keyup", "T", ->
    endPhrase()

  # Send data to player
  gatherData = ->
    rowCount = dataTable.handsontable('countRows')
    data = []
    for i in [1...rowCount-1] by 1
      item = [dataTable.handsontable('getDataAtCell', i, 1), dataTable.handsontable('getDataAtCell', i, 2), JSON.parse(dataTable.handsontable('getDataAtCell', i, 3))]
      if item[0] && item[1]
        data.push item
    return data

  $('.send-data-to-player').click ->
    phrasesMedia.mediaElement.stop()
    phrasesMedia.ended = false

    phrases.loadPhrases gatherData()
    $('.phrase-count').text(data.length)
    phrases.playPhrase 0

  $('.btn.save').click ->
    data = gatherData()
    for c in lessonComposition 
      for item in c
        if item.className == 'Phrases'
          item.phrases = data

    $('#lesson_composition').val(JSON.stringify(lessonComposition))
    $('form').submit()
