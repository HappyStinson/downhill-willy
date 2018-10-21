-- just a comment

-- This game requires level.lua
require('level')

function love.load()
  love.mouse.setVisible(false)
  level.load()
end

function love.update(dt)
  level.update(dt)
end

function love.draw()
  level.draw()
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

