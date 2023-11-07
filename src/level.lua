require 'src.whale'
require 'src.constants'
local audio = require 'src.audio'
Graphics = require 'src.graphics'

level = {}

-- LOAD
local function createBackgroundQuad()
  mountainQuad = Graphics:backgroundQuad(704)
  forestQuad = Graphics:backgroundQuad(423)
  images.bg_mnt1:setWrap("repeat")
  images.bg_mnt2:setWrap("repeat")
  images.bg_forest:setWrap("repeat")
end

local function loadImages()
  img_fn = {"bg_forest", "bg_mnt1", "bg_mnt2", "fg_snow", "ui_hiscore", "lanes", "logo", "obj_log", "obj_snowman", "obj_stone", "obj_tree", "player_idle", "player_run1", "player_run2", "ui_score", "sky", "vall"}
  Graphics:loadImages(img_fn)  
  createBackgroundQuad()
end

local function initLanes()
  level.lanes = {
    laneWidth = GAME_WIDTH,
    laneHeight = 20,
    laneLayers = 3,
    laneY = 50
  }
end

local function initAudio()
  audioSources = {
    idle = audio.streamLooped("yodel_idle"),
    yodel_intro = audio.stream("yodel_intro"),
    yodel_loop = audio.streamLooped("yodel_loop")
  }
  audioSources.idle:play()

  soundEffects = {
    fanfare = audio.soundEffect("fanfare"),
    obj_log = audio.soundEffect("crash-log"),
    obj_snowman = audio.soundEffect("crash-snowman"),
    obj_stone = audio.soundEffect("crash-stone"),
    obj_tree = audio.soundEffect("crash-tree")
  }
end

function level.load()
  Graphics:loadLevelAssets()
  loadImages()
  initLanes()
  initAudio()
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
  
  -- Keep track of current and best score
  score = 0
  hiscore = 0
  playerGotNewHighScore = false
  
  whale.load()
end

-- UPDATE
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
    soundEffects.fanfare:play()
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
        soundEffects[v.ID]:play()
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

function love.update(dt)
  if not isRunning then
    audioSources.yodel_intro:stop()
    audioSources.yodel_loop:stop()
    audioSources.yodel_loop:setPitch(1.0)
    audioSources.idle:play()
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
    audioSources.yodel_loop:setPitch(1 + (speed - 10) / 200) -- 1 -> 1.1
    
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
    Input:processCharacterMovementInput()
    whale.update(dt)
    
    if time > 2 then
      checkCollision()
    end
    
    removeObjects()
    
    if (not audioSources.yodel_intro:isPlaying()) and isRunning == true then
      audioSources.yodel_loop:play()
    end
  end
end

function level.drawPlayer()
  -- Draw whale according to game running state
  if not isRunning then
    Graphics:drawIdlePlayer(whale.x, whale.y, whale.offsetX, whale.offsetY)
  else
    if (#level.objects == 0) and isRunning then
      whale.playAnimation()
    end
  end
end

function level.startGame()
  if not isRunning then
    isRunning = true
    playerGotNewHighScore = false
    audioSources.idle:stop()
    
    if not audioSources.yodel_loop:isPlaying() then
      audioSources.yodel_intro:play()
    end
  end
end