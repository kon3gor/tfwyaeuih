local states

-- Images
local play_text
local title
local wings_image
local demon_image
-- Tables
local demons = {}
local wings  = {}

--Values
local WIDTH
local HEIGHT


function states.prepare(play_text, title, wings_image, demon_image, demons, wings, WIDTH, HEIGHT)
  play_text = play_text
  title = title
  wings_image = wings_image
  demon_image = demon_image

  demons = demons
  wings = wings

  HEIGHT = HEIGHT
  WIDTH = WIDTH

  return
end


function states.DrawMenu()
  love.graphics.draw(play, (HEIGHT - 512)/2, 700)  
  love.graphics.draw(title, (HEIGHT - 512)/2, 200)  
       
  for k,v in pairs(wings) do  
    love.graphics.draw(wings_image, 0, v.Y, 0, 0.5, 0.5)  
  end  
     
  for k, v in pairs(demons) do  
    love.graphics.draw(demon_image, 1000, v.Y, 0, 0.7, 0.7)  
  end
  return
end


function states.UpdateMenu()
  for k, v in pairs(wings) do  
    v.Y = v.Y + 1  
    if v.Y == (WIDTH - 50) then  
      v.Y = -300
    end                                     
  end
                                               
  for k, v in pairs(demons) do  
    v.Y = v.Y - 1  
    if v.Y == -150 then  
      v.Y = HEIGHT       
    end                   
  end
  return
end


return states
