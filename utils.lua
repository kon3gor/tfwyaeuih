local utils = {}

function utils.approximate(x, y, ox, oy, speed)
  local vy = -((y - oy) / math.sqrt((y-oy)*(y-oy) + (y-oy)*(y-oy))) * speed
  local vx = -((x - ox) / math.sqrt((x-ox)*(x-ox) + (y-oy)*(y-oy))) * speed
  return y+vy, x+vx
end
  
function utils.changeMainWeapon(player, sx, sy, ex, ey)
  player.mainWeapon.sx = sx
  player.mainWeapon.sy = sy
  player.mainWeapon.ex = ex
  player.mainWeapon.ey = ey
end

function utils.ignore(item, other)
  if other.name == 'bullet' then return nil
  elseif other.name:find('eye') then return nil
  elseif other.name == 'player' then return 'touch'
  end
end

return utils
