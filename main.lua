
require 'src.level'
Graphics = require 'src.graphics'
Input = require 'src.input'

function love.load()
  Graphics:createWindow(true)
  Input:initJoystick()
  level.load()
end