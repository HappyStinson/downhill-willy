-- Simple LÖVE Joystick and Keyboard input
local Input = {}

require 'src.level'
require 'src.whale'

local inputState = {
    keyPressed = {
        up = false,
        down = false,
    },
    gamepadButtonPressed = {
        dpadUp = false,
        dpadDown = false,
    }
}

function Input:initJoystick()
  local joysticks = love.joystick.getJoysticks()
  joystick = joysticks[1]
end

local function startGame()
  level.startGame()
end

function Input:keyPressed(key)
    if key == "up" or key == "w" then
        inputState.keyPressed.up = true
    elseif key == "down" or key == "s" then
        inputState.keyPressed.down = true

    elseif key == controls.toggle_fullscreen then
        level.toggleFullscreen()
        level.toggleMouseVisibility()
    elseif key == controls.start then
        startGame()
      end
end

function Input:gamepadButtonPressed(button)
    if button == "dpup" then
        inputState.gamepadButtonPressed.dpadUp = true
    elseif button == "dpdown" then
        inputState.gamepadButtonPressed.dpadDown = true
    elseif button == "start" then
        startGame()
    end
end

function Input:processCharacterMovementInput()
    local upReleased = inputState.keyPressed.up or inputState.gamepadButtonPressed.dpadUp
    local downReleased = inputState.keyPressed.down or inputState.gamepadButtonPressed.dpadDown

    if upReleased then
        whale.moveUp()
        inputState.keyPressed.up = false
        inputState.gamepadButtonPressed.dpadUp = false
    end

    if downReleased then
        whale.moveDown()
        inputState.keyPressed.down = false
        inputState.gamepadButtonPressed.dpadDown = false
    end
end

function love.keypressed(key)
    if key == controls.quit then
        love.event.quit()
    end

    Input:keyPressed(key)
end

function love.gamepadpressed(joystick, button)
    Input:gamepadButtonPressed(button)
end

return Input