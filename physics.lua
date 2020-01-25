local physics = {}

function physics.inCircle(player, radius, h, w)
  local goal_x = player.x + player.vx
  local goal_y = player.y + player.vy
  local norm_x = goal_x - h/2
  local norm_y = goal_y - w/2
  love.graphics.print(norm_x .. 'x' .. norm_y, 100, 120);
  return ((norm_x * norm_x) + (norm_y * norm_y)) < (radius*radius)
end

return physics
