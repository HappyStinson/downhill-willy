-- This file describes our level

level = {}
require 'whale'
require 'constants'
local colors = require 'colors'

local function loadImages()
  img_fn = {"bg_forest", "bg_mnt1", "bg_mnt2", "fg_snow", "ui_hiscore", "lanes", "logo", "obj_log", "obj_snowman", "obj_stone", "obj_tree", "player_idle", "player_run1", "player_run2", "ui_score", "sky", "vall"}
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

local function initFont()
  fonts = {
    score = love.graphics.newFont("assets/font_score.otf", 22),
    high_score = love.graphics.newFont("assets/font_hiscore.otf", 27),
    instructions = love.graphics.newFont("assets/font_score.otf", 27),
  }
end

local function initLanes()
  level.lanes = {
    laneWidth = GAME_WIDTH,
    laneHeight = 20,
    laneLayers = 3,
    laneY = 50
  }
end

local function createAudioStream(filename, isLooping)
  local audio_source = love.audio.newSource("assets/" .. filename .. ".wav", "stream")
  audio_source:setLooping(isLooping)
  return audio_source
end

local function audioStreamLooped(filename)
  return createAudioStream(filename, true)
end

local function audioStream(filename)
  return createAudioStream(filename, false)
end

function level.load()
  loadImages()
  initFont()
  initLanes()
  level.objects = {}
  
  isRunning = false
  
  time = 0
  speed = 10
  
  offsets = {
    obj_log = {112, 47, 50},
    obj_snowman = {38, 105, 100},
    obj_stone = {33, 53, 55},
    obj_tree = {45, 107, 80}
  }
  
  bgOffsets = {
    mnt1 = 0,
    mnt2 = 0,
    forest = 0
  }
  
  laneYPos = {330, 250, 175}
  
  -- Initialize audio
  audio = {
    idle = audioStreamLooped("yodel_idle"),
    yodel_intro = audioStream("yodel_intro"),
    yodel_loop = audioStreamLooped("yodel_loop")
  }
  audio.idle:play()
  
  -- Keep track of current and best score
  score = 0
  hiscore = 0
  playerGotNewHighScore = false
  
  whale.load()
end

local function updateBackground(dt)
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

local function spawnRandomObject()
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

local function leaveRunningState()
  isRunning = false
  time = 0

  -- Check if player got new high score
  if score == hiscore then
    playerGotNewHighScore = true
  end

  score = 0
end

local function checkCollision()
  -- Only check collision with objects on same lane
  for _, v in ipairs(level.objects) do
    if v.lane == whale.lane or ((v.ID == "obj_log") and (v.lane == (whale.lane + 1))) then
      distance = math.abs(whale.x - v.x)
      
      if ((v.ID == "obj_log") and (v.lane == (whale.lane + 1))) and (distance < (offsets[v.ID][3])) or
         distance < (offsets[v.ID][3] / 2) then
        leaveRunningState()
      end
    end
  end
end

local function removeObjects()
  -- Remove all objects that have left the screen
  for _, v in ipairs(level.objects) do
    if v.x < -100 then
      table.remove(level.objects, _)
    end
  end
end

function level.update(dt)
  if not isRunning then
    audio.yodel_intro:stop()
    audio.yodel_loop:stop()
    audio.yodel_loop:setPitch(1.0)
    audio.idle:play()
  end
  
  if isRunning == true then
    isPaused = false
    
    -- Speed changes with time
    -- Better to only update speed if less than 30 ... to avoid a lot of heavy calculation.
    time = time + dt
    speed = 10 + time / 15
    if speed >= 30 then
      speed = 30
    end
    audio.yodel_loop:setPitch(1 + (speed - 10) / 200) -- 1 -> 1.1
    
    score = score + (speed / 2) * dt
    if score > hiscore then
      hiscore = score
    end
    
    updateBackground(dt)
    
    -- Spawn new objects
    if love.math.random(1, 100) <= 1 then
      spawnRandomObject()
    end
    
    -- Update object positions
    for _, v in ipairs(level.objects) do
      v.x = v.x - dt * 100 * speed
      v.y = laneYPos[v.lane] + 0.335 * v.x
    end
    
    -- Update whale position
    whale.update(dt)
    
    if time > 2 then
      checkCollision()
    end
    
    removeObjects()
    
    if (not audio.yodel_intro:isPlaying()) and isRunning == true then
      audio.yodel_loop:play()
    end
  end
end

local function drawBackground()
  -- Draw the beautiful sky
  love.graphics.draw(images.sky, 0, 0)
  love.graphics.draw(images.bg_mnt1, mountainQuad, 0, 0, 0, 1, 1, bgOffsets.mnt1, 0)
  love.graphics.draw(images.bg_mnt2, mountainQuad, 0, 0, 0, 1, 1, bgOffsets.mnt2, 0)
  love.graphics.draw(images.bg_forest, forestQuad, 0, 191, 0, 1, 1, bgOffsets.forest, 0)
end

local function drawImage(image, x, y)
  love.graphics.draw(image, x, y)
end

local function drawForeground()
  -- Draw at bottom left
  drawImage(images.fg_snow, 0, 272)
end

local function drawLanes()
  drawImage(images.lanes, 0, 130)
  drawImage(images.vall, 0, 105)
  drawImage(images.vall, 0, 345)
end

local function drawObjects()
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
end

local function setColor(color, alpha)
  if alpha then
    local color_table = colors[color]
    table.insert(color_table, alpha)
    love.graphics.setColor(color_table)
  else 
    love.graphics.setColor(colors[color])
  end
end

local function drawGUI(controls)
  local center = {
    x = GAME_WIDTH / 2,
    y = GAME_HEIGHT / 2
  }

  -- Score and hiscore
  local limit = 200 -- Wrap the line after this many horizontal pixels
  drawImage(images.ui_score, center.x - (images.ui_score:getWidth() / 2), 0)
  drawImage(images.ui_hiscore, 1280 - images.ui_hiscore:getWidth(), 100)
  drawImage(images.logo, 50, GAME_HEIGHT - images.logo:getHeight() * 1.3)
  
  local score_text = string.format("%.0f M", score)
  love.graphics.setFont(fonts.score)
  love.graphics.printf(score_text, center.x - 135, 53, limit, "right")
  
  setColor("black")
  score_text = string.format("%.0f M", hiscore)
  love.graphics.setFont(fonts.high_score)
  love.graphics.printf(score_text, 1075, 145, limit, "right")
  setColor("white")
  
  if not isRunning then
    if playerGotNewHighScore then
      setColor("black")
      love.graphics.printf("New High Score! " .. score_text, 0, center.y, GAME_WIDTH, "center")
    end

    -- Show info centered on the screen
    local instructions = {
      string.format("Press %s to start skiing", string.upper(controls.start)),
      string.format("%s toggles fullscreen", string.upper(controls.toggle_fullscreen)),
      string.format("%s quits the game", string.upper(controls.quit))
    }
    
    local font_height = fonts.instructions:getHeight()
    
    setColor("light-blue accent-4", .3)
    love.graphics.rectangle("fill", 0, center.y, GAME_WIDTH, font_height * (#instructions + 2))
    setColor("white")
    love.graphics.setFont(fonts.instructions)

    for i = 1, #instructions do
      love.graphics.printf(instructions[i], 0, center.y + (font_height * i), GAME_WIDTH, "center")
    end
  end
end

function level.draw(controls)
  drawBackground()
  drawForeground()
  drawLanes()
  drawObjects()
  
  -- Draw whale according to game running state
  if not isRunning then
    love.graphics.draw(images.player_idle, whale.x, whale.y, 0, 1, 1, whale.offsetX, whale.offsetY)
  else
    if (#level.objects == 0) and isRunning then
      whale.playAnimation()
    end
  end
  
  -- Draw user interface
  drawGUI(controls)
end

local function toggleFullscreen()
  local isFullscreen = not love.window.getFullscreen()
  love.window.setFullscreen(isFullscreen, "desktop")
end

local function toggleMouseVisibility()
  local state = not love.mouse.isVisible()
  love.mouse.setVisible(state)
end

local function startGame()
  isRunning = true
  playerGotNewHighScore = false
  audio.idle:stop()
  if not audio.yodel_loop:isPlaying() then
    audio.yodel_intro:play()
  end
end

function level.keypressed(key, controls)
  if not isRunning then
    if key == controls.toggle_fullscreen then
      toggleFullscreen()
      toggleMouseVisibility()
    end
    if key == controls.start then
      startGame()
    end
  else
    whale.keypressed(key)
  end
end