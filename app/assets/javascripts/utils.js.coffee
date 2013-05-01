Object.keys = Object.keys or (o) ->
  result = []
  for name of o
    result.push name  if o.hasOwnProperty(name)
  result