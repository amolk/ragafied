$ ->
  return unless $('body.lessons.edit').length > 0

  phrases = null
  for k,v of Lesson.instance.medias
    if v.className == 'Phrases'
      phrases = v

  return unless phrases?

  