modulejs.define "search", ["engines"], (Engines) ->
  engines:  ->
    search: (keyword) ->
      for engine in [ "google", "yahoo", "bing", "a2ma"]
        Engines.engine(engine).search(keyword)