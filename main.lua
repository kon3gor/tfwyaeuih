local bump = require 'bump'
local physics = require 'physics'
local ctrs = require 'constructors'
local utils = require 'utils'
local config = require 'config'
local player = {}
local enemies = {}
local bullets = {}
local level = 1

local background
local bullet_image
local eye_image, eye_quads = nil, {}
local level1music

local globalTime = 0
local frames = 0
-- state description
-- 0 -- menu
-- 1 -- game
-- 2 -- game over
local globalState = 0

local world = bump.newWorld()

local WIDTH = 1280
local HEIGHT = 1024
local PLAYER_VELOCITY = 5
local VELOCITY_DEC = 0.4
local COOLDOWN = 1.0

function love.load()
  math.randomseed(os.time())
  love.window.setMode(WIDTH, HEIGHT)
  player.x  = 630
  player.y  = 630
  player.vx = 0
  player.vy = 0
  player.h  = 13
  player.w  = 13
  player.pHealth = 7
  player.lastHitTime = 0
  player.lookDirection = 'down'
  player.isMoving = false
  player.name = 'player'
  player.killCounter = 0
  player.mainWeapon = {sx = 0, sy = 0, ex = 0, ey = 0}
  world:add(player, player.x, player.y, player.w, player.h)

  player.image = love.graphics.newImage('res/sprite_sheet.png')
  bullet_image = love.graphics.newImage('res/fireball.png')
  background   = love.graphics.newImage('res/1level_background.png')
  eye_image    = love.graphics.newImage('res/eye_sheet.png')

  level1music = love.audio.newSource('res/level1.mp3', 'stream')
  level1music:setLooping(true)

  for x = 0, 64, 32 do
    table.insert(eye_quads, love.graphics.newQuad(x, 0, 32, 32, eye_image:getDimensions()))
  end

  table.insert(bullets, ctrs.new_bullet(900, 100, player.x, player.y))
  table.insert(bullets, ctrs.new_bullet(100, 900, player.x, player.y))
  table.insert(bullets, ctrs.new_bullet(900, 900, player.x, player.y))
  table.insert(bullets, ctrs.new_bullet(100, 100, player.x, player.y))
  for k, v in pairs(bullets) do
    world:add(v, v.x, v.y, 8, 8)
    -- print(tostring(k) .. ': ' .. tostring(v))
  end
end

function love.update(dt)
  if globalState == 0 then
    if love.keyboard.isDown('1') then
      globalState = 1
      love.audio.play(level1music)
    end
  elseif globalState == 1 then
    globalTime = globalTime + dt
    frames = frames + 1
    if 0.0056 >= math.random() and #enemies < config.levelProperties[level].maximumEnemies then
      print("New Enemy!")
      local enemy = ctrs.new_enemy(math.random(WIDTH), math.random(HEIGHT), 40, globalTime, 'eye'..tostring(math.random()))
      table.insert(enemies, enemy)
      world:add(enemy, enemy.x, enemy.y, 32, 32)
    end

    for k, v in pairs(bullets) do
      local actualX, actualY, cols, len = world:move(v, v.x+v.vx, v.y+v.vy, utils.ignore)
      v.x = actualX
      v.y = actualY
      for i = 1, len do
        if cols[i].other.name == 'player' and globalTime - player.lastHitTime >= COOLDOWN then
          player.pHealth = player.pHealth - 1
          player.lastHitTime = globalTime
          world:remove(v)
          table.remove(bullets, k)
        end
      end
    end

    for k, v in pairs(enemies) do
      local rndnum = function () return math.random(-20, 20) end
      local newX, newY = utils.approximate(v.x,v.y, player.x+rndnum(), player.y+rndnum(), 1)
      local actualX, actualY, cols, len = world:move(v, newY, newX, utils.ignore)
      if len == 0 then
        v.x = actualX
        v.y = actualY
      else
        for i = 1, len do
          if cols[i].other.name == 'player' and globalTime - player.lastHitTime >= COOLDOWN then
            player.pHealth = player.pHealth - 1
            player.lastHitTime = globalTime
          end
        end
      end
      if globalTime - v.lastShooted >= COOLDOWN and 0.0625 >= math.random() then
        v.lastShooted = globalTime
        local new_bullet = ctrs.new_bullet(v.x, v.y, player.x, player.y)
        table.insert(bullets, new_bullet)
        world:add(new_bullet, new_bullet.x, new_bullet.y, 8, 8)
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

    if love.keyboard.isDown('n') then
      local items,len = world:querySegment( player.mainWeapon.sx, player.mainWeapon.sy
                                          , player.mainWeapon.ex, player.mainWeapon.ey
                                          , function (other) 
                                              return other.name:find('eye')
                                            end
                                          )
      if (len >= 1) then
        print(items[1].name .. ' ' .. items[1].health)
        for i = 1, len do
          items[i].health = items[i].health - 1
          local ind = 0
          if items[i].health <= 0 then
            for k, v in pairs(enemies) do
              if v.name == items[i].name then ind = k end
            end
            world:remove(items[i])
            table.remove(enemies, ind)
            player.killCounter = player.killCounter + 1
          end
        end
      end
    end

    if physics.inCircle(player, config.levelProperties[level].radius, WIDTH, HEIGHT) then
      local actualX, actualY, cols, len = world:move(player, player.x + player.vx, player.y + player.vy, utils.ignore)
      player.x = actualX
      player.y = actualY
    end

    player.vx = player.vx + VELOCITY_DEC * (player.vx > 0 and -1 or 1)
    player.vy = player.vy + VELOCITY_DEC * (player.vy > 0 and -1 or 1)
    if math.abs(player.vx) <= 0.65 then player.vx = 0 end
    if math.abs(player.vy) <= 0.65 then player.vy = 0 end
    player.isMoving = player.vx == 0 and player.vy == 0

    if player.pHealth <= 0 then
      globalState = 2
    end
    if player.killCounter >= config.levelProperties[level].kills then
      level = level + 1
      player.killCounter = 0
    end
  end
end

function love.draw()
  if globalState == 0 then
    love.graphics.print("Press space")
  elseif globalState == 1 then
    -- Draw background
    local radiusOfLevel = config.levelProperties[level].radius
    love.graphics.draw(background, WIDTH/2-radiusOfLevel-10, HEIGHT/2-radiusOfLevel-10)

    -- Draw Player
    love.graphics.setColor(1, 1, 1)
    -- player.lookDirection {up, down, left, right}
    local row = {down=0, up=1, right=2, left=3}
    local direction = row[player.lookDirection] * 32
    if not player.isMoving then
      local playerframe = (math.floor((frames + 4) / 8) % 2 + 1) * 32
      love.graphics.draw(player.image, love.graphics.newQuad(playerframe,direction,32,32,player.image:getDimensions()), player.x-10, player.y-10)
    else
      love.graphics.draw(player.image, love.graphics.newQuad(0,direction,32,32,player.image:getDimensions()), player.x-10, player.y-10)
    end
    -- Draw bullets
    for k, v in pairs(bullets) do
      love.graphics.draw(bullet_image, v.x, v.y)
    end

    -- Draw enemies
    for k, v in pairs(enemies) do
      love.graphics.draw(eye_image, eye_quads[math.floor(frames / 8) % 2 + 1], v.x, v.y)
    end

    -- Draw Hit Box
    -- love.graphics.setColor(0.5, 1, 0.25)
    -- love.graphics.rectangle('fill', player.x, player.y, 13, 13)
    -- Draw circles
    love.graphics.setColor(0.5, 0.67, 0.25)
    love.graphics.circle('line', WIDTH/2, HEIGHT/2, radiusOfLevel)
    love.graphics.print(player.pHealth, 100, 100);
    love.graphics.print(player.lastHitTime, 100, 120);

    love.graphics.setColor(1, 1, 1, 0.5)
    if love.keyboard.isDown('n') then
      if player.lookDirection == 'up' then
        love.graphics.rectangle('fill', player.x, 0, 10, player.y)
        utils.changeMainWeapon(player, player.x, 0, player.x + 10, player.y)
      end
      if player.lookDirection == 'down' then
        love.graphics.rectangle('fill', player.x, player.y, 10, HEIGHT-player.y)
        utils.changeMainWeapon(player, player.x, player.y, player.x + 10, player.y + HEIGHT - player.y)
      end
      if player.lookDirection == 'right' then
        love.graphics.rectangle('fill', player.x, player.y, WIDTH-(player.x/2), 10)
        utils.changeMainWeapon(player, player.x, player.y, player.x+WIDTH-(player.x/2), player.y+10)
      end
      if player.lookDirection == 'left' then
        love.graphics.rectangle('fill', 0, player.y, player.x, 10)
        utils.changeMainWeapon(player, 0, player.y, player.x, player.y+10)
      end
    end
    love.graphics.setColor(1,1,1)
  end
end

