require 'src.constants'
local colors = require 'src.colors'

Graphics = {}

function Graphics:createWindow(isFullscreen)
  gameCanvas = love.graphics.newCanvas(GAME_WIDTH, GAME_HEIGHT)

  -- Start the game in fullscreen
  love.window.setFullscreen(isFullscreen, "desktop")
  love.mouse.setVisible(false)
end

function Graphics:toggleFullscreen()
  local isFullscreen = not love.window.getFullscreen()
  love.window.setFullscreen(isFullscreen, "desktop")
end

function Graphics:toggleMouseVisibility()
  local state = not love.mouse.isVisible()
  love.mouse.setVisible(state)
end

local function initFont()
  fonts = {
    score = love.graphics.newFont("assets/font_score.otf", 22),
    high_score = love.graphics.newFont("assets/font_hiscore.otf", 27),
    instructions = love.graphics.newFont("assets/font_score.otf", 27),
  }
end

function Graphics:loadLevelAssets()
  initFont()
end

function Graphics:loadImages(filenames)
  images = {}
  for _, v in ipairs(filenames) do
      images[v] = love.graphics.newImage("assets/"..v..".png")
  end
end

function Graphics:backgroundQuad(height)
  mapWidth = images.bg_mnt1:getWidth() * 2
  return love.graphics.newQuad(0, 0, mapWidth, height, 1547, height)
end

local function drawImage(image, x, y)
  love.graphics.draw(image, x, y)
end

function Graphics:drawImage(drawable, x, y, offsetX, offsetY)

  love.graphics.draw(drawable, x, y, 0, 1, 1, offsetX, offsetY)
end

function Graphics:drawIdlePlayer(x, y, offsetX, offsetY)
  love.graphics.draw(images.player_idle, x, y, 0, 1, 1, offsetX, offsetY)
end

local function drawLevelBackground()
  -- Draw the beautiful sky
  love.graphics.draw(images.sky, 0, 0)
  love.graphics.draw(images.bg_mnt1, mountainQuad, 0, 0, 0, 1, 1, bgOffsets.mnt1, 0)
  love.graphics.draw(images.bg_mnt2, mountainQuad, 0, 0, 0, 1, 1, bgOffsets.mnt2, 0)
  love.graphics.draw(images.bg_forest, forestQuad, 0, 191, 0, 1, 1, bgOffsets.forest, 0)
end

local function drawImage(image, x, y)
  love.graphics.draw(image, x, y)
end

local function drawLevelForeground()
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

local function drawLevelLayers()
  drawLevelBackground()
  drawLevelForeground()
  drawLanes()
  drawObjects()

  level.drawPlayer()
end

local function getScale()
  local scaleX = love.graphics.getWidth() / GAME_WIDTH
  local scaleY = love.graphics.getHeight() / GAME_HEIGHT
  
  if scaleY < 1 and scaleY < scaleX then
    return scaleY
  else
    return scaleX
  end
end

local function getMarginY(scale)
  return (love.graphics.getHeight() - GAME_HEIGHT * scale) / 2
end

local function getMarginX(scale)
  return (love.graphics.getWidth() - GAME_WIDTH * scale) / 2
end

function love.draw()
    love.graphics.setCanvas(gameCanvas)
    
    drawLevelLayers()
    drawGUI(controls)
    
    love.graphics.setCanvas()
    local scale = getScale()
    love.graphics.draw(gameCanvas, getMarginX(scale), getMarginY(scale), 0, scale, scale)
end

return Graphics