local utils = {}

function utils.approximate(x, y, ox, oy, speed)
  local vx = -((y - oy) / math.sqrt((y-oy)*(y-oy) + (y-oy)*(y-oy))) * speed
  local vy = -((x - ox) / math.sqrt((x-ox)*(x-ox) + (y-oy)*(y-oy))) * speed
  return y+vy, x+vx
end
  
return utils
