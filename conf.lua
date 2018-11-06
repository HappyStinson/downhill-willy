-- Configuration settings

function love.conf(t)
  t.identity = "downhill-willy"                -- The name of the save directory (string)
  t.version = "11.1"
  
  t.window.title = "Downhill Willy - BOSS Jam 2014"
  t.window.icon = "assets/logo.png"
  t.window.width = 1280
  t.window.height = 720

  -- Disable unused modules
  t.modules.data = false               -- Enable the data module (boolean)
  t.modules.joystick = false           -- Enable the joystick module (boolean)
  t.modules.physics = false            -- Enable the physics module (boolean)
  t.modules.system = false             -- Enable the system module (boolean)
  t.modules.thread = false             -- Enable the thread module (boolean)
  t.modules.touch = false              -- Enable the touch module (boolean)
  t.modules.video = false              -- Enable the video module (boolean)
end

controls = {
  toggle_fullscreen = "f",
  quit = "escape",
  start = "space"
}