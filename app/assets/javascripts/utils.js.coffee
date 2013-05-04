Object.keys = Object.keys or (o) ->
  result = []
  for name of o
    result.push name  if o.hasOwnProperty(name)
  result

String::beginsWith = (str) -> if @match(new RegExp "^#{str}") then true else false
String::endsWith = (str) -> if @match(new RegExp "#{str}$") then true else false