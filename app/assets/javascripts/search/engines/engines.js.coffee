modulejs.define "engines", ["engine", "engines/a2ma"], (Engine, A2MA) ->
  list =
    a2ma: A2MA
  engine: (name) ->
    unless list[name]
      list[name] = new Engine(name)
    list[name]