audio = {}

local function audioFilename(filename)
  return string.format("assets/audio/%s.wav", filename)
end

local function createAudioStream(filename, isLooping)
  local audio_source = love.audio.newSource(audioFilename(filename), "stream")
  audio_source:setLooping(isLooping)
  return audio_source
end

function audio.streamLooped(filename)
  return createAudioStream(filename, true)
end

function audio.stream(filename)
  return createAudioStream(filename, false)
end

function audio.soundEffect(filename)
  return love.audio.newSource(audioFilename(filename), "static")
end

return audio