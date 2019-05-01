if CASTLE_PREFETCH then
  CASTLE_PREFETCH({
    'background.lua',
    'game.lua',
    'loving.lua',
    
    'assets/Fipps-Regular.ttf',
    
    'assets/menu_back.png',
    'assets/transition.png',
    
    "assets/sound/blaze.wav",
    "assets/sfx/blaze_theme.wav",
    "assets/sfx/card.wav",
    "assets/sfx/joker.wav",
    "assets/sfx/mirror.wav",
    "assets/sfx/select.wav",
    
    "assets/cards/1.png",
    "assets/cards/2.png",
    "assets/cards/3.png",
    "assets/cards/4.png",
    "assets/cards/5.png",
    "assets/cards/6.png",
    "assets/cards/7.png",
    "assets/cards/8.png",
    "assets/cards/blaze.png",
    "assets/cards/joker.png",
    "assets/cards/mirror.png",
    "assets/cards/card_back.png",
    "assets/cards/card_back_light.png"
    
  })
end
require("game")
require("background")
require("loving")


-- local table = love.graphics.newImage( "table.png" )

GAME_WIDTH = 1000
GAME_HEIGHT = 600

bordure = 60
zoom = 1

function love.load()
  love.math.setRandomSeed(os.time())
  init_game()
end

function love.draw()
  -- love.graphics.push()  
  -- WINDOW STUFF --
    local width  = love.graphics.getWidth()
    local height = love.graphics.getHeight()
    
    -- draw background
    -- fill_back({.1, .1, .3}, width, height)
    
    -- sets zoom so game sticks to either height or width
    zoom = height/(GAME_HEIGHT+  bordure)
    if (width < (GAME_WIDTH + bordure) * zoom) then zoom = width / (GAME_WIDTH + bordure) end
      
    -- centers screen
    love.graphics.translate(0.5 * (width - (GAME_WIDTH + bordure/2 ) * zoom),  0.5 * (height - (GAME_HEIGHT + bordure/2) * zoom))
    love.graphics.scale(zoom)  
    
    -- after this point, everything is in 800 x 600
    
    color( 1, 1, 1 )
  --
  
  draw_game()
  
  -- love.graphics.pop()  
end

function love.update(dt)
  update_game(dt)
end

function get_mouse_pos()

  local truex , truey = love.mouse.getPosition()
  
  local width  = love.graphics.getWidth()
  local height = love.graphics.getHeight()
  local x = (truex - (width -  (GAME_WIDTH  + bordure/2) * zoom) / 2) / zoom
  local y = (truey - (height - (GAME_HEIGHT + bordure/2) * zoom) / 2) / zoom
  
  return x, y

end

function vertical_write(str, x, y)
  for i = 1, #str do
      local c = str:sub(i,i)
      draw_text(c, x, y +(i-1) * str_height(c))
  end
end

function vertical_write_funny(str, x, y, col)
  local col = col or {1, 1, 1}
  for i = 1, #str do
    local c = str:sub(i,i)
    local x = x + cos((writing_offset_timer/2 + (i-1)/#str) * math.pi ) * 13
    local y = y +(i-1) * str_height(c) + cos(writing_offset_timer * 6) * 5
    color(.2, .2, .2)
    draw_text(c, x + 5, y + 5)
    color(.3, .3, .3)
    draw_text(c, x + 3, y + 3)
    color(col)
    draw_text(c, x, y)
  end
end