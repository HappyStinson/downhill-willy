-- This file describes our level

level = {}
require('whale')

-- LOVE callback functions
function level.load()
  level.loadImages()
  level.initFont()
  level.initLanes()
  level.objects = {}

  collision = false
  isRunning = false

  time = 0
  speed = 10 -- Go from 5 to 30

  
  -- Store info about x, y, width for objects
  offsets = { }
  offsets["obj_log"] = { 112, 47, 50 }
  offsets["obj_snowman"] = { 38, 105, 100 }
  offsets["obj_stone"] = { 33, 53, 55 }
  offsets["obj_tree"] = { 45, 107, 80 }
  bgOffsets = { mnt1 = 0, mnt2 = 0, forest = 0 }

  laneYPos = { }
  laneYPos[1] = 330
  laneYPos[2] = 250
  laneYPos[3] = 175

  -- Initialize audio
  audio = {}
  audio["idle"] = love.audio.newSource("assets/yodel_idle.wav")
  audio["yodel_intro"] = love.audio.newSource("assets/yodel_intro.wav")
  audio["yodel_loop"] = love.audio.newSource("assets/yodel_loop.wav")

  audio["idle"]:setLooping(true)
  audio["yodel_intro"]:setLooping(false)
  audio["yodel_loop"]:setLooping(true)

  audio["idle"]:play()

  -- Keep track of current and best score
  score = 0
  hiscore = 0

  -- Because black is nice!
  -- love.graphics.setColor(0, 0, 0, 255)

  whale.load()
end

function level.update(dt)
  if not isRunning then
    audio["yodel_intro"]:stop()
    audio["yodel_loop"]:stop()
    audio["idle"]:play()
  end

  if isRunning == true then
    
    -- Speed changes with time
    time = time + dt
    speed = 10 + time / 15
    if speed >= 30 then
      speed = 30
    end

    score = score + (speed / 2) * dt
    if score > hiscore then
      hiscore = score
    end

    level.updateBackground(dt)

    -- Spawn new objects
    if love.math.random(1, 100) <= 1 then
      level.spawnRandomObject()
    end

    -- Update object positions
    for _, v in ipairs(level.objects) do
      v.x = v.x - dt * 100 * speed
      v.y = laneYPos[v.lane] + 0.335 * v.x
    end

    -- Update whale position
    whale.update(dt)

    if time > 2 then
      level.checkCollision()
    end
    
    level.removeObjects()

    if (not audio["yodel_intro"]:isPlaying()) and isRunning == true then
      audio["yodel_loop"]:play()
    end
  end
end

function level.draw()
  level.drawBackground()
  level.drawForeground()
  level.drawLanes()
  level.drawObjects()
  
  -- Draw whale according to game running state
  if not isRunning then
    love.graphics.draw(images.player_idle, whale.x, whale.y, 0, 1, 1, whale.offsetX, whale.offsetY)
  else
    if (#level.objects == 0) and isRunning then
     whale.playAnimation()
    end  
  end

  -- Draw user interface
  level.drawUI()
end

function level.keypressed(key)
  if key == " " then
    isRunning = true
    audio["idle"]:stop()
    if not audio["yodel_loop"]:isPlaying() then
      audio["yodel_intro"]:play()
    end
  end
  if isRunning == true then
    whale.keypressed(key)
  end
end

-- Helper functions
function level.loadImages()
  img_fn = { "bg_forest", "bg_mnt1", "bg_mnt2", "fg_snow", "ui_hiscore", "lanes", "logo", "obj_log", "obj_snowman", "obj_stone", "obj_tree", "player_idle", "player_run1", "player_run2", "ui_score", "sky", "vall" }
  images = {}
  for _, v in ipairs(img_fn) do
    images[v] = love.graphics.newImage("assets/"..v..".png")
  end

  -- Create a quad for the background
  mapWidth = images.bg_mnt1:getWidth() * 2
  mountainQuad = love.graphics.newQuad(0, 0, mapWidth, 704, 1547, 704) 
  forestQuad = love.graphics.newQuad(0, 0, mapWidth, 423, 1547, 423) 
 images.bg_mnt1:setWrap("repeat")
 images.bg_mnt2:setWrap("repeat")
 images.bg_forest:setWrap("repeat")
end

function level.initFont()
  fonts = {}
  fonts["score"] = love.graphics.newFont("assets/font_score.otf", 22)
  fonts["hiscore"] = love.graphics.newFont("assets/font_hiscore.otf", 27)
end

function level.initLanes()
  level.lanes = {}
  level.laneWidth = love.window.getWidth()
  level.laneHeight = 20
  level.laneLayers = 3
  level.laneY = 50

  color = { r = 50, g = 50, b = 50, a = 50 }
  --[[
  for layer, level.laneLayers, 1 do
    level.addLane(0 + level.laneY * layer, level.laneHeight, color)
  end
  ]]--
end

function level.updateBackground(dt)
  bgOffsets.mnt1 = bgOffsets.mnt1 + dt * 5 * speed
  bgOffsets.mnt2 = bgOffsets.mnt2 + dt * 10 * speed
  bgOffsets.forest = bgOffsets.forest + dt * 40 * speed
  
  if bgOffsets.mnt1 >= (mapWidth / 2) then
    bgOffsets.mnt1 = 0
  end
  if bgOffsets.mnt2 >= (mapWidth / 2) then
    bgOffsets.mnt2 = 0
  end
  if bgOffsets.forest >= (mapWidth / 2) then
    bgOffsets.forest = 0
  end
end

function level.spawnRandomObject()
  -- Randomize object type and lane
  lane = love.math.random(1, 3)
  objType = love.math.random(1, 100)
  local object = {}
  object.lane = lane

  if lane == 2 or lane == 3 then
    if objType <= 10 then
      object.ID = "obj_log"
    elseif objType <= 30 then
      object.ID = "obj_snowman"
    elseif objType <= 60 then
      object.ID = "obj_stone"
    else
      object.ID = "obj_tree"
    end
  else
    if objType <= 20 then
      object.ID = "obj_snowman"
    elseif objType <= 60 then
      object.ID = "obj_stone"
    else
      object.ID = "obj_tree"
    end
  end

  object.x = 1400
  object.y = getY(2, 1400)
  table.insert(level.objects, object)
end

function level.checkCollision()
  -- Only check collision with objects on same lane
  for _, v in ipairs(level.objects) do
    if v.lane == whale.lane or ((v.ID == "obj_log") and (v.lane == (whale.lane + 1))) then
      distance = math.abs(whale.x - v.x)

      if ((v.ID == "obj_log") and (v.lane == (whale.lane + 1))) and (distance < (offsets[v.ID][3])) then
        collision = true
        isRunning = false
        time = 0
        score = 0
      elseif distance < (offsets[v.ID][3] / 2) then
        collision = true
        isRunning = false
        time = 0
        score = 0
      end
    end
  end
end

function level.removeObjects()
  -- Remove all objects that have left the screen
  for _, v in ipairs(level.objects) do
    if v.x < -100 then
      table.remove(level.objects, _)
    end
  end
end

function level.drawBackground()
  -- Draw the beautiful sky
  love.graphics.draw(images.sky, 0, 0)
  love.graphics.draw(images.bg_mnt1, mountainQuad, 0, 0, 0, 1, 1, bgOffsets.mnt1, 0)
  love.graphics.draw(images.bg_mnt2, mountainQuad, 0, 0, 0, 1, 1, bgOffsets.mnt2, 0)
  love.graphics.draw(images.bg_forest, forestQuad, 0, 191, 0, 1, 1, bgOffsets.forest, 0)
end

function level.drawForeground()
  -- Draw at bottom left
  drawImage(images.fg_snow, 0, 272)
end

function level.drawLanes()
  drawImage(images.lanes, 0, 130)
  drawImage(images.vall, 0, 105)
  drawImage(images.vall, 0, 345)
end

function level.drawObjects()
  table.sort(level.objects, function(a, b) return a.lane > b.lane end)
  playerDrawn = true 

  for _, v in ipairs(level.objects) do
    if v.lane == 3 then
      love.graphics.draw(images[v.ID], v.x, v.y, 0, 1, 1, offsets[v.ID][1], offsets[v.ID][2])
    end
    if (whale.lane == 3) and isRunning then
      whale.playAnimation()
      playerDrawn = false
    end
  end
  for _, v in ipairs(level.objects) do
    if v.lane == 2 then
      love.graphics.draw(images[v.ID], v.x, v.y, 0, 1, 1, offsets[v.ID][1], offsets[v.ID][2])
    end
    if whale.lane == 2 and isRunning then
      whale.playAnimation()
      playerDrawn = false
    end
  end
  for _, v in ipairs(level.objects) do
    if v.lane == 1 then
      love.graphics.draw(images[v.ID], v.x, v.y, 0, 1, 1, offsets[v.ID][1], offsets[v.ID][2])
    end
    if whale.lane == 1 and isRunning then
      whale.playAnimation()
      playerDrawn = false
    end
  end

  --[[
  for _, v in ipairs(level.objects) do
    if whale.lane >= v.lane and playerDrawn then
      love.graphics.draw(images.temp_player, whale.x, whale.y, 0, 1, 1, whale.offsetX, whale.offsetY)
      playerDrawn = false
    end
    love.graphics.draw(images[v.ID], v.x, v.y, 0, 1, 1, offsets[v.ID][1], offsets[v.ID][2])
  end
  --]]
end

function level.drawUI()
  -- Score and hiscore
  drawImage(images.ui_score, love.window.getWidth() / 2 - images.ui_score:getWidth() / 2, 0) 
  drawImage(images.ui_hiscore, 1280 - images.ui_hiscore:getWidth(), 100) 
  drawImage(images.logo, 50, love.window.getHeight() - images.logo:getHeight() * 1.3) 

  -- love.graphics.setColor(0, 0, 0, 0)

  rounded = string.format("%.0f", score)
  love.graphics.setFont(fonts.score)
  love.graphics.printf(rounded.." M", love.window.getWidth() / 2 - 135, 53, 200, "right")

  rounded = string.format("%.0f", hiscore)
  love.graphics.setFont(fonts.hiscore)
  love.graphics.printf(rounded.." M", 1075, 145, 200, "right") --love.window.getWidth() - 105, 0, 200, "right")

end

-- Test of global function
function drawImage(image, x, y)
  love.graphics.draw(image, x, y)
end

