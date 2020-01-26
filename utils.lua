local utils = {}

function utils.approximate(x, y, ox, oy, speed)
  local vx = -((x - ox) / math.sqrt((x-ox)*(x-ox) + (y-oy)*(y-oy))) * speed
  local vy = -((y - oy) / math.sqrt((y-oy)*(y-oy) + (y-oy)*(y-oy))) * speed
  return x+vx, y+vy
end
  
return utils
