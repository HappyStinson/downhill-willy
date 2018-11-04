-- just a comment

-- This game requires level.lua
require('level')
require('constants')

function love.load()
  love.mouse.setVisible(false)
  gameCanvas = love.graphics.newCanvas(GAME_WIDTH, GAME_HEIGHT)
  level.load()
  -- Start the game in fullscreen
  love.window.setFullscreen(true, "desktop")
end

function love.update(dt)
  level.update(dt)
end

function love.draw()
  love.graphics.setCanvas(gameCanvas)
  level.draw(controls)
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
  if key == controls.quit then
    love.event.quit()
  end
  
  level.keypressed(key, controls)
end