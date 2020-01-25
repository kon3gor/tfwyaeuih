local bump = require 'bump'
local physics = require 'physics'
local ctrs = require 'constructors'
local player = {}
local enemies = {}
local bullets = {}

local background
local bullet_image
local eye_image, eye_quads = nil, {}

local globalTime = 0
local radiusOfLevel = 150

local world = bump.newWorld()

local HEIGHT = 1280
local WIDTH = 1024
local PLAYER_VELOCITY = 5
local VELOCITY_DEC = 0.1

function love.load()
  love.window.setMode(HEIGHT, WIDTH)
  player.x  = 630
  player.y  = 630
  player.vx = 0
  player.vy = 0
  player.h  = 13
  player.w  = 13
  player.health = 7
  player.lastHitTime = 0;
  player.lookDirection = '';
  world:add(player, player.x, player.y, player.w, player.h)

  player.image = love.graphics.newImage('res/sprite_sheet.png')
  bullet_image = love.graphics.newImage('res/fireball.png')
  background   = love.graphics.newImage('res/1level_background.png')
  eye_image    = love.graphics.newImage('res/eye_sheet.png')

  -- for x = 0, 64, 32 do
  --   for y = 0, 64, 32 do
  --     table.insert(eye_quads, love.graphics.newQuad(x, y, 32, 32))
  --   end
  -- end

  for x = 0, 64, 32 do
    table.insert(eye_quads, love.graphics.newQuad(x, 0, 32, 32, eye_image:getDimensions()))
  end

  table.insert(bullets, ctrs.new_bullet(900, 100, player.x, player.y))
  table.insert(bullets, ctrs.new_bullet(100, 900, player.x, player.y))
  table.insert(bullets, ctrs.new_bullet(900, 900, player.x, player.y))
  table.insert(bullets, ctrs.new_bullet(100, 100, player.x, player.y))
  for k, v in pairs(bullets) do
    world:add(v, v.x, v.y, 8, 8)
    print(tostring(k) .. ': ' .. tostring(v))
  end
end

function love.update(dt)
  globalTime = globalTime + dt
  if 0.05555555555555556 >= math.random() then
    local enemy = ctrs.new_enemy(math.random(HEIGHT), math.random(WIDTH), 200, globalTime, 'eye')
    table.insert(enemies, enemy)
    world:add(enemy, enemy.x, enemy.y, 32, 32)
  end
  for k, v in pairs(bullets) do
    local actualX, actualY, cols, len = world:move(v, v.x+v.vx, v.y+v.vy)
    v.x = actualX
    v.y = actualY
    for i = 1, len do
      if cols[i].other.health then
        cols[i].other.health = cols[i].other.health - 1
        world:remove(v)
        table.remove(bullets, k)
      end
    end
  end

  if love.keyboard.isDown('up') then
    player.vy = -PLAYER_VELOCITY
    player.lookDirection = 'up'
  end
  if love.keyboard.isDown('down') then
    player.vy = PLAYER_VELOCITY
    player.lookDirection = 'down'
  end
  if love.keyboard.isDown('left') then
    player.vx = -PLAYER_VELOCITY
    player.lookDirection = 'left'
  end
  if love.keyboard.isDown('right') then
    player.vx = PLAYER_VELOCITY
    player.lookDirection = 'right'
  end

  if physics.inCircle(player, radiusOfLevel, HEIGHT, WIDTH) then
    local actualX, actualY, cols, len = world:move(player, player.x + player.vx, player.y + player.vy)
    player.x = actualX
    player.y = actualY
  end


  player.vx = player.vx + VELOCITY_DEC * (player.vx > 0 and -1 or 1)
  player.vy = player.vy + VELOCITY_DEC * (player.vy > 0 and -1 or 1)
  if math.abs(player.vx) <= 0.35 then player.vx = 0 end
  if math.abs(player.vy) <= 0.35 then player.vy = 0 end
end

function love.draw()
  love.graphics.draw(background, HEIGHT/2-radiusOfLevel-10, WIDTH/2-radiusOfLevel-10)
  -- Draw Player
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(player.image, love.graphics.newQuad(0,0,32,32,player.image:getDimensions()), player.x-10, player.y-10)

  -- Draw bullets
  for k, v in pairs(bullets) do
    love.graphics.draw(bullet_image, v.x, v.y)
  end

  -- Draw enemies
  for k, v in pairs(enemies) do
    love.graphics.draw(eye_image, v.x, v.y)
  end

  -- Draw Hit Box
  -- love.graphics.setColor(0.5, 1, 0.25)
  -- love.graphics.rectangle('fill', player.x, player.y, 13, 13)
  -- Draw circles
  love.graphics.setColor(0.5, 0.67, 0.25)
  love.graphics.circle('line', HEIGHT/2, WIDTH/2, radiusOfLevel)
  love.graphics.print(player.health, 100, 100);
  love.graphics.print(globalTime, 100, 120);

  love.graphics.setColor(1, 1, 1, 0.5)
  if love.keyboard.isDown('z') then
    if player.lookDirection == 'up' then
      love.graphics.rectangle('fill', player.x, 0, 10, player.y)
    end
    if player.lookDirection == 'down' then
      love.graphics.rectangle('fill', player.x, player.y, 10, HEIGHT-player.y)
    end
    if player.lookDirection == 'right' then
      love.graphics.rectangle('fill', player.x, player.y, WIDTH-(player.x/2), 10)
    end
    if player.lookDirection == 'left' then
      love.graphics.rectangle('fill', 0, player.y, player.x, 10)
    end
  end
end

