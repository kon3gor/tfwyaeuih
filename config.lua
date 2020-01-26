local config = {}
config.levelProperties = {
  {radius = 150, kills = 20, maximumEnemies =  4},
  {radius = 160, kills = 25, maximumEnemies =  5},
  {radius = 170, kills = 30, maximumEnemies =  6},
  {radius = 160, kills = 35, maximumEnemies =  7},
  {radius = 200, kills = 40, maximumEnemies =  8},
  {radius = 210, kills = 45, maximumEnemies =  9},
  {radius = 230, kills = 50, maximumEnemies = 10},
  {radius = 240, kills = 55, maximumEnemies = 11},
  {radius = 260, kills = 70, maximumEnemies = 12},
}

config.spells = {
  ["y"] = {name = "KTD", description = "killall enemies", duration = 3},
  ["6"] = {name = "KTB", description = "killall bullets", duration = 2}
}
return config
