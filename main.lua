-- just a comment

-- This game requires level.lua
require('level')
require('constants')

function love.load()
  love.mouse.setVisible(false)
  gameCanvas = love.graphics.newCanvas(GAME_WIDTH, GAME_HEIGHT)
  level.load()
end

function love.update(dt)
  level.update(dt)
end

function love.draw()
  love.graphics.setCanvas(gameCanvas)
  level.draw()
  love.graphics.setCanvas()
  local scale = getScale()
  love.graphics.draw(gameCanvas, getMarginX(scale), getMarginY(scale), 0, scale, scale)
end

function getScale()
  local scaleX = love.graphics.getWidth() / GAME_WIDTH
  local scaleY = love.graphics.getHeight() / GAME_HEIGHT
  if scaleY < 1 and scaleY < scaleX then
    return scaleY
  else
    return scaleX
  end
end

function getMarginY(scale)
  return (love.graphics.getHeight() - GAME_HEIGHT * scale) / 2
end

function getMarginX(scale)
  return (love.graphics.getWidth() - GAME_WIDTH * scale) / 2
end

function love.keypressed(key)
  -- Toggle fullscreen with f
  if key == "f" then
    local isFullscreen = not love.window.getFullscreen()
    love.window.setFullscreen(isFullscreen, "desktop")
    local state = not love.mouse.isVisible()
    love.mouse.setVisible(state)
  end
  
  -- Allow user to quit with escape
  if key == "escape" then
    love.event.quit()
  end
  
  level.keypressed(key)
end
