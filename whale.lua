-- Code for the player
whale = {}

function whale.load()
  xPositions = { 130, 208, 280 }
  whale.animationTime = 1

  -- Start position
  whale.lane = 2
  whale.x = xPositions[2]
  whale.y = getY(whale.lane, whale.x) 
  whale.offsetX = 56
  whale.offsetY = 93 
end

function whale.update(dt)
  whale.animationTime = whale.animationTime + dt

  whale.x = xPositions[whale.lane]
  whale.y = getY(whale.lane, whale.x) 
end

function whale.keypressed(key)
  if key == "up" and whale.lane < 3 then
    whale.lane = whale.lane + 1
  elseif key == "down" and whale.lane > 1 then
    whale.lane = whale.lane - 1
  end
end

function whale.playAnimation()
  if whale.animationTime % 1 <= 0.5 then
    love.graphics.draw(images.player_run1, whale.x, whale.y, 0, 1, 1, whale.offsetX, whale.offsetY)
  else
    love.graphics.draw(images.player_run2, whale.x, whale.y, 0, 1, 1, whale.offsetX, whale.offsetY)
  end
end

function getY(lane, x)
  local laneYPos = { 330, 250, 175 } 
  return laneYPos[lane] + (0.335 * x)
end
  
