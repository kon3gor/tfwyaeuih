local ctrs = {}

function ctrs.new_bullet(x, y, px, py)
  local bullet = {}
  bullet.x = x
  bullet.y = y
  bullet.vx = -((x - px) / math.sqrt((x-px)*(x-px) + (y-py)*(y-py)))
  bullet.vy = -((y - py) / math.sqrt((x-px)*(x-px) + (y-py)*(y-py)))
  return bullet
end

function ctrs.new_enemy(x, y, health, currentTime, name)
  local enemy = {}
  enemy.x = x
  enemy.y = y
  enemy.w = 16
  enemy.h = 16
  enemy.health = health
  enemy.lastShooted = 0
  enemy.name = name
  return enemy
end

return ctrs
