-- Configuration settings

function love.conf(t)
  t.title = "Downhill Willy - BOSS Jam 2014"
  t.window.icon = "assets/logo.png"
  t.version = "11.1"
  t.window.width = 1280
  t.window.height = 720
end

controls = {
  toggle_fullscreen = "f",
  quit = "escape",
  start = "space"
}