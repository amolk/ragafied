class Media
  constructor: (@compositionItem, @lesson, @next) ->
    @title = @compositionItem.mediaTitle
    @url = @lesson.audio_files[@compositionItem.mediaTitle].url if @lesson.audio_files[@compositionItem.mediaTitle]
    @config = @compositionItem.config || {}
    @container = @lesson.innerContainer

    if @url
      @audioElementID = 'audio_' + Math.floor(Math.random()*99999999)

      source = $('<source/>')
        .attr('src', @url)
        .attr('type', 'audio/mpeg')
      audio = $('<audio/>')
        .attr('id', @audioElementID)
        .append(source)
        .append("Your browser does not support the audio tag.")
      $(document.body)
        .append(audio)

      @mediaElement = new MediaElement(@audioElementID)
      @lesson.audio_files[@compositionItem.mediaTitle]["loaded"] = true

      @mediaElement.addEventListener "canplay", =>
        @mediaElementReady = true
        if @autoPlay
          @mediaElement.play()

    else
      @playNext()

  play: ->
    @drawInterface()
    if @mediaElementReady
      @mediaElement.play()
    else
      @autoPlay = true

  playNext: ->
    @mediaElement.stop() if @mediaElement
    @ended = true
    @next.play() if @next

  playPause: ->
    return if !@mediaElement
    if @mediaElement.paused
      @mediaElement.play()
    else
      @mediaElement.pause()

  drawInterface: ->

  setVolume: (volume) ->
    $(@mediaElement).animate
      volume: volume
    , 300

  setCurrentTime: (time) ->
    v = @mediaElement.volume
    @mediaElement.setVolume(0)
    @mediaElement.currentTime = time
    @mediaElement.setVolume(v)

class Finished extends Media
  drawInterface: ->
    super()
    @container
      .html('')
      .append(
        $('<h1></h1>').text('Finished')
      )
      .append(
        $('<p>Did you like the lesson? Let us know at contact@ragafied.com.<p>')
      )

class Tanpura extends Media
  constructor: (@compositionItem, @lesson, @next) ->
    @className = 'Tanpura'
    super(@compositionItem, @lesson, @next)
    @mediaElement.setVolume(0)
    @mediaElement.addEventListener 'ended', =>
      @mediaElement.play() unless @ended

  drawInterface: ->
    super()
    $(document).bind "keydown", "t", =>
      @playPause()

class Audio extends Media
  play: ->
    @mediaElement.addEventListener 'timeupdate', =>
      return if @ended      
      percent = @mediaElement.currentTime * 100.0 / @mediaElement.duration
      @progressBar.css('width', percent + '%')
    super()

    @mediaElement.addEventListener 'ended', =>
      return if @ended      
      @playNext()

    @lesson.medias['tanpura'].setVolume(@config.tanpuraVolume) if @config.tanpuraVolume != null && @lesson.medias['tanpura']

  drawInterface: ->
    @container
      .html('')
      .append(
        $('<h1></h1>').text(@title)
      )
      .append(
        $('<div class="introduction-progress"></div>')
          .append('<div class="progress progress-striped"><div class="bar" style="width: 0%;"></div></div>')
      )
      .append('<div class="btn btn-mini skip-introduction-button">Skip ' + @title + '</div>')

    @progressBar = $('.introduction-progress .bar')
    $('.skip-introduction-button').click =>
      @playNext()
      return false

Singer = 
  guru: 0
  student: 1

class Phrase
  constructor: (@index, @info, @phrases) ->
    @start = @info[0]
    @end = @info[1]
    @config = @info[2] || {}
    @length = @end - @start
    @setSinger Singer.guru

  getSinger: -> 
    @_singer

  setSinger: (@_singer) ->
    console.log("singer = " + @_singer)

  setCurrentTime: (currentTime) ->

    currentPhraseTime = currentTime - @start
    if currentPhraseTime > 0 and currentPhraseTime < @length
      @phrases.phraseProgressDisplay.css('top', (currentPhraseTime * 1.0 / @length) + "em")

    if currentTime + 0.3 > @end
      # if we finished guru's turn 
      if @getSinger() == Singer.guru
        unless @jumpScheduled
          console.log("setCurrentTime " + currentTime + ", end " + @end)
          @jumpScheduled = true
          setTimeout =>
            return if @ended

            console.log("jump received")
            @setSinger Singer.student
            if @config.a
              @phrases.lesson.medias[@config.a].play()
            @phrases.setCurrentTime(@start)
            @phrases.setStudentVolume()
            @jumpScheduled = false

          , (@end - currentTime - 0.05) * 1000
          console.log("scheduled jump after " + (@end - currentTime - 0.05))
      # see if we want to repeat
      else if @phrases.repeat
        unless @jumpScheduled
          @jumpScheduled = true
          setTimeout =>
            return if @ended

            @setSinger Singer.guru
            @phrases.setGuruVolume()
            @phrases.setCurrentTime(@start)
            @jumpScheduled = false
            @phrases.repeat = false

          , (@end - currentTime - 0.05) * 1000
      else
        # move on to the next phrase
        @phrases.setCurrentPhraseIndex @phrases.getCurrentPhraseIndex() + 1

        # reset this phrase
        @reset()

  playPause: ->
    if @phrases.mediaElement.paused
      @phrases.lesson.medias['tanpura'].mediaElement.play() if @phrases.lesson.medias['tanpura']
      if @getSinger() == Singer.guru
        @phrases.setGuruVolume()
      else
        @getSinger() == Singer.guru
      @phrases.mediaElement.play()
      @phrases.lesson.medias[@config.a].mediaElement.play() if @config.a
    else
      @phrases.setStudentVolume()
      @phrases.mediaElement.pause()
      @phrases.lesson.medias[@config.a].mediaElement.pause() if @config.a

  reset: ->
    @phrases.lesson.medias[@config.a].mediaElement.stop() if @config.a
    @jumpScheduled = false
    @setSinger Singer.guru
    @phrases.setGuruVolume()
    @phrases.repeat = false


class Phrases extends Media
  constructor: (@compositionItem, @lesson, @next) ->
    @className = 'Phrases'
    super(@compositionItem, @lesson, @next)
    @loadPhrases(@compositionItem.phrases)
    

  loadPhrases: (p) ->
    @phrases = p
    ps = []
    for p, i in @phrases
      ps.push(new Phrase(i, p, this))

    @compositionItem.phrases = @phrases = ps

  setGuruVolume: ->
    @setVolume(@config.guruVolume)
    @lesson.medias['tanpura'].setVolume(@config.guruTanpuraVolume) if @lesson.medias['tanpura']

  setStudentVolume: ->
    @setVolume(@config.studentVolume)
    @lesson.medias['tanpura'].setVolume(@config.studentTanpuraVolume) if @lesson.medias['tanpura']

  getCurrentPhraseIndex: -> @_currentPhraseIndex
  setCurrentPhraseIndex: (@_currentPhraseIndex) -> 
    if @_currentPhraseIndex > @phrases.length - 1
      # finished all phrases
      @_currentPhraseIndex = @phrases.length - 1
      @playPause()
      @playNext()
    else
      console.log("currentPhraseIndex = " + @_currentPhraseIndex)
      @currentPhraseDisplay.text(@_currentPhraseIndex + 1) if @currentPhraseDisplay
      @setGuruVolume()

  getCurrentPhrase: -> @phrases[@_currentPhraseIndex]

  drawInterface: ->
    @container
      .html('')
      .append(
        $('<div class="raga"></div>').html("RAGA " + @lesson.data.raga_name)
      )
      .append(
        $('<div class="guru"></div>').html(@lesson.data.guru_name)
      )
      .append(
        $('<div class="phrase-title"></div>').html("PHRASE")
      )
      .append(
        $('<div class="phrase-progress"></div>')
      )
      .append(
        $('<div class="phrase-current"></div>').html("1")
      )
      .append(
        $('<div class="phrase-count"></div>').html("of " + @phrases.length)
      )
      .append(
        $('<ul class="pager"><li><a class="previous" href="#">&larr; Previous</a></li><li><a class="next" href="#">Next &rarr;</a></li></ul>')
      )

    # remember ui elements for easy access
    @currentPhraseDisplay = $('.phrase-current')
    @phraseProgressDisplay = $('.phrase-progress')

    # hook up next and previous phrase buttons
    @container.find('.pager a.next').click =>
      return false if @ended
      if @getCurrentPhraseIndex() < @phrases.length - 1
        @playPhrase(@getCurrentPhraseIndex() + 1)
      return false

    @container.find('.pager a.previous').click =>
      return false if @ended
      if @getCurrentPhraseIndex() > 0
        @playPhrase(@getCurrentPhraseIndex() - 1)
      return false

    # click anywhere or hit spacebar to play/pause
    # $(document).click => @playPause()
    $(document).bind "keydown", "space", => @playPause()
    $(document).bind "keydown", "l", => 
      @repeat = true

  playPause: ->
    @getCurrentPhrase().playPause() if !@ended && @getCurrentPhrase()

  play: ->
    super()
    @setCurrentPhraseIndex 0

    @mediaElement.addEventListener 'timeupdate', =>
      return if @ended

      currentTime = @mediaElement.currentTime
      @getCurrentPhrase().setCurrentTime(currentTime)

  playPhrase: (index) ->
    return if @phrases.length - 1 < index
    @mediaElement.pause()
    @getCurrentPhrase().reset() if @getCurrentPhrase()

    phrase = @phrases[index]
    if phrase
      @mediaElement.setCurrentTime(phrase.start)
      @setCurrentPhraseIndex(index)
      @mediaElement.play()

mediaClasses = {
  "Audio": Audio,
  "Phrases": Phrases,
  "Tanpura": Tanpura,
  "Finished": Finished
}

class Composition
  constructor: (@composition, @lesson) ->
    for list in @composition
      listReverse = list.slice(0).reverse()

      nextMedia = null
      media = null
      for item in listReverse
        className = null
        if (item.className in Object.keys(mediaClasses))
          media = new mediaClasses[item.className](item, @lesson, nextMedia)
          @lesson.medias[item.mediaTitle] = media
        else
          throw "Unknown media class: " + item.className

        @lesson[item.mediaTitle] = media
        nextMedia = media

      nextMedia.play() if @lesson.autoPlay

class Lesson
  constructor: (@data, @autoPlay) ->
    @drawInterface()

    @audio_files = @data.audio_files
    @medias = {}

    @composition = new Composition(@data.lesson_composition, this)

    for title, info of @audio_files
      item = {mediaTitle: title}
      @medias[title] = new Media(item, this) unless info.loaded

  drawInterface: ->
    $('#lesson-container')
      .html('')
      .append('<div id="lesson-container-inner"></div>')
      .append('<div id="lesson-controls"></div>')

    @container = $('#lesson-container')
    @innerContainer = $('#lesson-container-inner')

$ ->
  return unless $('body.lessons.show').length > 0
  Lesson.instance = new Lesson(lesson, true)

window.Lesson = Lesson

###
  # loops = [[2.7702212677001956, 9.184221267700195], [11.991261260986327, 17.198261260986328], [17.526979934692385, 26.414979934692383], [27.735749694824218, 32.03874969482422], [33.234138275146485, 37.658138275146484], [38.33461004638672, 45.07061004638672], [44.37819735717773, 49.481197357177734], [48.36060409545898, 51.935604095458984], [50.920908386230465, 58.26390838623047], [59.959832641601565, 63.26283264160156], [62.93683978271484, 66.99983978271484], [66.009435546875, 69.096435546875], [68.05724621582031, 71.02424621582031], [70.36301135253906, 72.14601135253906], [72.41117504882813, 76.09817504882812], [81.04170166015625, 89.05670166015625], [90.26760961914063, 95.41860961914062], [94.87684741210937, 99.74984741210938], [102.96509576416015, 110.90909576416016], [109.30560375976563, 115.13760375976562], [115.28742578125, 119.71142578125]]
  drone = undefined
  player = undefined
  canPlay = false
  currentLoop = 0
  currentLoopCount = 0
  jumpScheduled = false
  repeat = false
  firstTimeStart = true

  smoothSetVolume = (mediaElement, volume) ->
    $(mediaElement).animate
      volume: volume
    , 1000
  formatNumber = (value, format) ->
    throw "Only 00 format supported."  unless format is "00"
    if value > 9
      "" + value
    else
      "0" + value
  setCurrentLoop = (value) ->
    currentLoop = value
    $("#phrase-title").text "PHRASE"
    $("#current-phrase").text formatNumber(value + 1, "00")
    $("#total-phrases").text "of " + formatNumber(loops.length, "00")
  setCurrentLoopCount = (value) ->
    currentLoopCount = value
    if value % 2 is 0
      $("#teacher").show()
      $("#student").hide()
      smoothSetVolume drone, 0.2  if drone
      smoothSetVolume player, 1.0  if player
    else
      $("#teacher").hide()
      $("#student").show()
      smoothSetVolume drone, 0.5  if drone
      smoothSetVolume player, 0.2  if player
  
  # drone.play()
  
  # console.log("current loop = " + currentLoop + ", loop count = " + currentLoopCount + ", currentTime = " +  currentTime + ", current loop end time = " + loops[currentLoop][1] + ", jumpScheduled = " + jumpScheduled)
  
  # If current loop is about to end
  
  # console.log("approaching loop point")
  
  # console.log("already scheduled")
  
  # If first time through loop, do loop
  
  # console.log("Looping in " + (loops[currentLoop][1] - currentTime) * 1000)
  
  # console.log("Seeking to " + loops[currentLoop][0])
  
  # console.log("currentLoop = " + currentLoop + " loops[currentLoop + 1] = " + loops[currentLoop + 1])
  
  #player.play(); 
  playpause = ->
    
    # if (!canPlay)
    #   return
    if firstTimeStart
      firstTimeStart = false
      setCurrentLoop 0
      setCurrentLoopCount 0
    drone.play()  if drone
    if player
      if player.paused
        player.play()
      else
        player.pause()
  
  drone = new MediaElement("drone")
  droneStart = 0
  droneEnd = 30.012
  drone.addEventListener "timeupdate", ->
    if drone.currentTime + 2 > droneEnd
      setTimeout (->
        drone.currentTime = droneStart
      ), (droneEnd - drone.currentTime) * 1000

  drone.addEventListener "loadeddata", (e) ->
    console.log e

  drone.addEventListener "canplay", ->
    drone.currentTime = 3
    smoothSetVolume drone, 0.2

  player = new MediaElement("player")
  player.addEventListener "timeupdate", ->
    currentTime = player.currentTime
    currentPhraseTime = currentTime - loops[currentLoop][0]
    currentPhraseLength = loops[currentLoop][1] - loops[currentLoop][0]
    console.log currentPhraseTime
    if currentPhraseTime > 0 and currentPhraseTime < currentPhraseLength
      progressBarTop = 21 + 72 * currentPhraseTime / currentPhraseLength
      console.log "currentPhraseLength = " + currentPhraseLength
      $("#current-phrase-progress").show().css "top", progressBarTop
    else
      $("#current-phrase-progress").hide()
    if currentTime + 0.5 > loops[currentLoop][1]
      unless jumpScheduled
        if currentLoopCount <= 0
          jumpScheduled = true
          setTimeout (->
            setCurrentLoopCount currentLoopCount + 1
            jumpScheduled = false
            player.setCurrentTime loops[currentLoop][0]
          ), (loops[currentLoop][1] - currentTime) * 1000
        else
          if repeat
            setCurrentLoopCount -1
            jumpScheduled = false
            repeat = false
          else
            if currentLoop < loops.length - 1
              setTimeout (->
                jumpScheduled = false
              ), (loops[currentLoop + 1][0] - currentTime) * 1000
              setCurrentLoop currentLoop + 1
              setCurrentLoopCount 0
              jumpScheduled = true
              repeat = false

  player.addEventListener "canplay", ->
    canPlay = true
    $("#current-phrase").text "START!"

  $("#repeat-button").click ->
    repeat = true  if currentLoopCount >= 0

  firstTimeStart = true
  $(document).click playpause
  $(document).bind "keydown", "space", playpause
  $(document).bind "keydown", "t", ->
    if drone
      if drone.paused
        drone.play()
      else
        drone.pause()

###
