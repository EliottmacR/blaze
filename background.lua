
require("loving")

TIME_PASSED = 0


tab_cards_background = {
  cards = {}, 
  xs = -90, 
  ys = 20, 
  nbcardh = 6 , 
  nbcardv = 4 , 
  hspacing = 0 ,
  vspacing = 0,   
  sizeh = 0,
  sizev = 0
}

cards = {}
CARD_WIDTH    = 0
CARD_HEIGHT   = 0
TRANSFORMED_CARD_WIDTH  = 0
TRANSFORMED_CARD_HEIGHT = 0
RATIO_CARD_WIDTH  = 0
RATIO_CARD_HEIGHT = 0

function init_background()

  init_assets()
  TIME_PASSED = 0
  local t = tab_cards_background
  
  local xx = rnd(-20, 20)
  local yy = rnd(-70, 0)
  
  t.sizeh = GAME_WIDTH  / (t.nbcardh - 1)
  t.sizev = GAME_HEIGHT / (t.nbcardv - 1)
  
  t.hspacing = t.sizeh - TRANSFORMED_CARD_WIDTH
  t.vspacing = t.sizev - TRANSFORMED_CARD_HEIGHT  
      
  for i = 0, t.nbcardh-1 do
    for j = 0, t.nbcardv-1 do
     local c ={
                x = xx + (i * t.sizeh  ), -- % (GAME_WIDTH + sizeh*2)  - sizeh,
                y = yy + (j * t.sizev  ), -- % (GAME_HEIGHT + sizev*2) - sizev 
                w = TRANSFORMED_CARD_WIDTH,
                h = TRANSFORMED_CARD_HEIGHT
              }
      set_background_card_state(c)
      table.insert(t.cards, c)
    end
  end
end  

function init_assets()
  
  cards[-1] = love.graphics.newImage( "assets/cards/card_back_light.png")
  cards[0]  = love.graphics.newImage( "assets/cards/card_back.png")

  table.insert(cards,love.graphics.newImage( "assets/cards/1.png" ))
  table.insert(cards,love.graphics.newImage( "assets/cards/2.png" ))
  table.insert(cards,love.graphics.newImage( "assets/cards/3.png" ))
  table.insert(cards,love.graphics.newImage( "assets/cards/4.png" ))
  table.insert(cards,love.graphics.newImage( "assets/cards/5.png" ))
  table.insert(cards,love.graphics.newImage( "assets/cards/6.png" ))
  table.insert(cards,love.graphics.newImage( "assets/cards/7.png" ))
  table.insert(cards,love.graphics.newImage( "assets/cards/8.png" ))
  -- table.insert(cards,love.graphics.newImage( "assets/cards/9.png" ))
  -- table.insert(cards,love.graphics.newImage( "assets/cards/10.png" ))
  table.insert(cards,love.graphics.newImage( "assets/cards/blaze.png" ))
  table.insert(cards,love.graphics.newImage( "assets/cards/mirror.png" ))
  table.insert(cards,love.graphics.newImage( "assets/cards/joker.png" ))
  
  CARD_WIDTH = cards[0]:getWidth()
  CARD_HEIGHT = cards[0]:getHeight()
  TRANSFORMED_CARD_WIDTH =  95 -- transformed
  TRANSFORMED_CARD_HEIGHT = 135 
  RATIO_CARD_WIDTH =  TRANSFORMED_CARD_WIDTH/ CARD_WIDTH-- real
  RATIO_CARD_HEIGHT = TRANSFORMED_CARD_HEIGHT/ CARD_HEIGHT
  
end 

function draw_background()
  for i, c in pairs(tab_cards_background.cards) do
    local rw = 1
    if c.turning then rw = cos(TIME_PASSED * c.rs + c.t) end
    
    local face = cards[0]
    
    if rw < 0 then
      face = cards[c.value]
    end
    
    local x = c.x + rw * (RATIO_CARD_WIDTH - TRANSFORMED_CARD_WIDTH/2)
    local y = c.y
    
    color(0, 0, 0)
    draw_fill_rect(
          x + 20, 
          y + 20, 
          TRANSFORMED_CARD_WIDTH * rw, 
          TRANSFORMED_CARD_HEIGHT)
          
    color(1, 1, 1)
    draw( face, 
          x , 
          y, 
          0, 
          RATIO_CARD_WIDTH * rw, 
          RATIO_CARD_HEIGHT)
  end
  -- hide_background()
end

function update_background(dt)
  TIME_PASSED = TIME_PASSED + dt
  color(1, 1, 1)
  local t = tab_cards_background
  for i, c in pairs(t.cards) do
  
    c.x = c.x + t.xs * dt
    c.y = c.y + t.ys * dt
    
    if c.x < - TRANSFORMED_CARD_WIDTH then
      c.x = GAME_WIDTH + t.hspacing
      set_background_card_state(c)
    end
    
    if c.y > GAME_HEIGHT then
      c.y = - t.sizev
      set_background_card_state(c)
    end      
  end
end

function set_background_card_state(c)
  c.t = irnd(100) / 100 -- time for rotation
  c.rs = 25/100 + irnd(150) / 100 -- rotation speed
  c.turning = irnd(10) >= 3 and true or false
  c.value = 1 + irnd(13)
end

function hide_background()
  color( .1, .1, .3 )
    
  local w = love.graphics.getWidth() / zoom
  local h = love.graphics.getHeight() / zoom
  
  draw_fill_rect(0, 0, -w, -h)
  draw_fill_rect(0, 0, -w,  h)
  draw_fill_rect(0, 0,  w, -h)
  
  draw_fill_rect(GAME_WIDTH, GAME_HEIGHT,  w,  h)
  draw_fill_rect(GAME_WIDTH, GAME_HEIGHT,  w, -h)
  draw_fill_rect(GAME_WIDTH, GAME_HEIGHT, -w,  h)  

end

