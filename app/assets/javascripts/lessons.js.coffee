$ ->
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

