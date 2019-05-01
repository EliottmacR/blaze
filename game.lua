
background = true
transition = false
mid_trans_call = nil

my_player = 2
turn_player = 0

p1_score = 0
p2_score = 0

local TIME_ANIM = 0
writing_offset_timer = 0
local menu = "start"
local c_wo = 0

-- mouse click but only the first frame
local clicked = true
  
local hand_clr = { r = 1, g = 1, b = 1}

--transition image

trs_img = love.graphics.newImage( "assets/transition.png")
cut_trs_img = {}

-- 1 vs 1 needs following

players_deck  = { [1] = {}, [2] = {} }

players_hand  = { [1] = {}, [2] = {} }

players_table = { [1] = {}, [2] = {} }

trash = {}
trash_p = {x = 0, y = 0}

hand_picked_done = false

b_d_to_pos = { [1] = {},
               [2] = {}}
time_in_1vs1 = -0.5
to_player = 0
play_x_game_over = 0
play_y_game_over = 0

blaze_deck = {}
move_angle_card = 0
card = {x = 0, y = 0}

initial_pos_cards_tab = { [1] = {}, [2] = {} }

-- returns index of hovered card, or nil
ind = nil

-- sound stuff
sounds = {}
sounds["card"] = love.audio.newSource("assets/sound/card.wav", "static")
sounds["select"] = love.audio.newSource("assets/sound/select.wav", "static")
sounds["joker"] = love.audio.newSource("assets/sound/joker.wav", "static")
sounds["mirror"] = love.audio.newSource("assets/sound/mirror.wav", "static")
sounds["blaze"] = love.audio.newSource("assets/sound/blaze.wav", "static")
sounds["theme"] = love.audio.newSource("assets/sound/blaze-theme.wav", "static")

-- go back stuff

barrowx = 0
barrowy = 0
barroww = 0
barrowh = 0
hover_back_arrow = false
back = love.graphics.newImage( "assets/menu_back.png")


-- playing background

stars = {}


-- INIT STUFF
function init_transition_img()

  local w = trs_img:getWidth()
  local h = trs_img:getHeight()
  
  canvas = love.graphics.newCanvas(w , h)
  love.graphics.setCanvas(canvas)
  draw( trs_img, 0, 0)
  love.graphics.setCanvas()
  
  w = w/10
  h = h/10
    
  for i = 0, 9 do
    for j = 0, 9 do
      cut_trs_img[i*10 + j + 1] = love.graphics.newImage(canvas:newImageData(nil, 1, j * w , i * h , w, h ))
    end
  end
  
  love.graphics.setCanvas()
end

function init_game()

  init_background()
  init_transition_img()

  love.graphics.setNewFont(64)
  title_w = str_width(TITLE)
  title_h = str_height(TITLE)
  love.graphics.setNewFont(48)
  
  
  barrowx = 0
  barrowy = 0
  barroww = back:getWidth()
  barrowh = back:getHeight()
  
  play_x_game_over = GAME_WIDTH/2
  play_y_game_over = GAME_HEIGHT*3/4

  sounds["theme"]:setLooping(true)
  sounds["theme"]:play()
  
  sounds["theme"]:setVolume(.5)
  
  sounds["card"]:setVolume(.4)
  
  sounds["joker"] :setVolume(.4)
  sounds["mirror"]:setVolume(.4)
  sounds["select"]:setVolume(.2)
  sounds["blaze"] :setVolume(.4)
  
  for i = 1, 1000 do
  
    stars[i] = {x = irnd(1000), y = irnd(600) }
  
  end
  
end


-- UPDATE STUFF
function update_game(dt)
  
  update_background(dt)
  
  writing_offset_timer = writing_offset_timer + dt  
  c_wo = cos(writing_offset_timer)  
  
  local x, y = get_mouse_pos() -- get the position of the mouse 
  
  if transition then x = -1 y = -1 end
  
  hover_back_arrow = false
    
  
  local r_b_mouse = false  
  if love.mouse.isDown(1) then -- right
    if not clicked then r_b_mouse = true clicked = true end
  else
    clicked = false
  end 
  
  if not (menu == "start") then 
    
    if (in_rect(x, y, barrowx , barrowy , barroww , barrowh)) then
      hover_back_arrow = true
      
      if (not transition) and r_b_mouse then 
        if(menu == "1vs1") then
          init_transition(transition_to_start) 
          
        elseif(menu == "rules") then
          init_transition(transition_to_start) 
        end
      end
      
    end
  end
  
  if(menu == "start") then
    
    if not transition then       
      if r_b_mouse then 
      
        local str = "Play"
        
        local xr = GAME_WIDTH  / 2 + c_wo * 6 - 15 - 15
        local yr = GAME_HEIGHT / 2  - 15 - 15
        local hr = str_height(str) 
        local wr = str_width(str) + 15 
        
        if (in_rect(x, y, xr - wr/2 , yr - hr/2, wr + 60, hr + 60)) then
          init_transition(transition_to_1vs1)   
          
        else
        
          local str = "Rules"
          local xr = GAME_WIDTH  / 2 + c_wo * 6 - 15 - 15
          local yr = GAME_HEIGHT / 2  - 15 - 15 + 150
          local h = str_height(str) 
          local w = str_width(str) + 15 
          
          if (in_rect(x, y, xr - wr/2 , yr - hr/2, wr + 60, hr + 60)) then
            init_transition(transition_to_rules) 
          end
        end
      end
    end
  end
    
  if(menu == "rules") then
  
    if not transition and r_b_mouse then 
      
      local str = "<"
      
      local xr = 80 + c_wo * 6 - 15 - 15
      local yr = GAME_HEIGHT - 30 - str_height(">")  - 15 - 15
      local hr = str_height(str) 
      local wr = str_width(str) + 15 
      
      if (in_rect(x, y, xr - wr/2 , yr - hr/2, wr + 60, hr + 60)) then
        current_tuto_page = max(1, current_tuto_page - 1)
      else
        
        local str = "<"
        local xr = GAME_WIDTH - str_width(">") - 40 + c_wo * 6 - 15 - 15
        local yr = GAME_HEIGHT - 30 - str_height(">")  - 15 - 15
        local h = str_height(str) 
        local w = str_width(str) + 15 
        
        if (in_rect(x, y, xr - wr/2 , yr - hr/2, wr + 60, hr + 60)) then
          current_tuto_page = min(#tutostr, current_tuto_page + 1)
        end
      end
    end
  end
  
  if(menu == "1vs1") then
  
    message = nil
    
    if not game_over then 
      time_in_1vs1 = time_in_1vs1 + dt
      
      if not deck_anim_ended then
      
        if time_in_1vs1 > 2 and #blaze_deck > 1 and not distribution_of_cards then 
          choose_new_card_to_move()
          time_in_1vs1 = 0
          distribution_of_cards = true
        end    
        
        if distribution_of_cards then
          if #blaze_deck > 0 then
            card = blaze_deck[#blaze_deck]
            
            angle = math.angle(card.x, card.y, to_pos.x ,to_pos.y )
            
            card.x = card.x + cos(angle) * dt * 100 * time_in_1vs1 * 40
            card.y = card.y + sin(angle) * dt * 100 * time_in_1vs1 * 40
           
            if(
              to_player == 1 and
              card.x > b_d_to_pos[to_player].x and
              card.y < b_d_to_pos[to_player].y
              )
              or
              (
              to_player == 2 and
              card.x < b_d_to_pos[to_player].x and
              card.y > b_d_to_pos[to_player].y
              )
            then  
              card.x = to_pos.x
              card.y = to_pos.y
              send_card_to_deck_of_player(to_player)
              if #blaze_deck > 0 then
                choose_new_card_to_move()
              else
                sounds["card"]:stop()
                sounds["blaze"]:play()
                deck_anim_ended = true
                time_in_1vs1 = -1
              end
            end
            
          else
            distribution_of_cards = false
          end
        end
        
      else
        if time_in_1vs1 > 0  then
        
          if to_game_over then game_over = true end
          
          if to_turn_player then 
            turn_player = get_next_player() 
            -- time_in_1vs1 = - .8
            to_turn_player = false
          end
                    
          if not hand_picked_done then 
            sounds["card"]:stop()
            sounds["card"]:play()
            from_deck_to_table(1)
            from_deck_to_table(2)
            hand_picked_done = true
            -- time_in_1vs1 = -.5
            
          elseif not picked_card then
            sounds["card"]:stop()
            sounds["card"]:play()
            picked_card = true
            pick_card_and_play_it()
            -- time_in_1vs1 = - 1.4
            
          elseif played_a_card or #players_hand[turn_player] == 0 then
          
            if played_a_card then
              sounds["card"]:stop()
              sounds["card"]:play()
              played_a_card = false
              use_card() -- only does something if card is special   
            end   
            
            local t_p_s = get_score(turn_player)  -- turn
            local nt_p_s = get_score(get_next_player()) -- next turn
            local a_hand_is_empty = (#players_hand[1] < 1 ) or (#players_hand[2] < 1)
            
            local next_p_hand_is_empty = #players_hand[get_next_player()] < 1
            
            
            
            if t_p_s < nt_p_s then
              end_game(get_next_player())
              
            elseif next_p_hand_is_empty and t_p_s ~= nt_p_s then
                end_game(turn_player)
            elseif t_p_s > nt_p_s then
              to_turn_player = true
            else
              init_pick_card() 
            end        
            
            time_in_1vs1 = - .8
            
          else
          
            if turn_player == 2 then
              ind = mouse_pos_to_card_on_screen(get_mouse_pos())
            else
              local order = {2, 13, 12, 11, 1, 3, 4, 5, 6, 7, 8, 9, 10}
              r_b_mouse = true
              
              -- bot playing
              
              --[[
                simple AI
                
                  looks for card in order and plays it,
                  
                  order : 2, 13, 12, 11, 1, 3, 4, 5, 6, 7, 8, 9, 10 
                  
                  
                  
                  simple. but, it has to win, so :
                  
                    - if plays 2, needs to choose a card that gets score > score p2 (do not include 2)
                      will find every card that respects this and play one at random
                    
                    - special cards do not really have any ranking
                     
                    - if number, will choose the first lowest number playable possible.
                      
                                        
                    
              
              --]]
              
              if choosing_state then
              
                -- played a 2
                  -- find every card that can be played, play one at random
                  
                local found_indexes = {}
                              
                for i = 1, 13 do
                    local hand_index = find_card(order[i], 2)
                    
                    if hand_index then
                      if order[i] > 10 or  p1_score + order[i] > p2_score - 1 then -- if number
                        table.insert(found_indexes, hand_index)
                      end 
                    end
                end
                
                if #found_indexes > 0 then 
                  ind = found_indexes[irnd(1, #found_indexes)]
                elseif #players_hand[2] < 1 then
                  players_hand[2][1] = {value = 2}
                  ind = 1
                else
                  ind = irnd(1, #players_hand[2])
                end
                
              else
              
                local found = false
                local i = 0
                while not (i > #order or found) do
                  i = i + 1
                  local hand_index = find_card(order[i], 1)
                  if hand_index then 
                  
                    if not ((i > 4) and (p1_score + order[i] < p2_score)) then
                      ind = hand_index 
                      found = true
                    end
                    
                  end                  
                end
                
                if not found then 
                  ind = irnd2(1, #players_hand[1])
                end
              end
              p1_score = get_score(1) 
              p2_score = get_score(2)
            end
            
            if #players_hand[1] < 1 and choosing_state then 
              players_hand[1][1] = {value = 2}
              ind = 1
            end
            
            if ind and r_b_mouse and not game_over then
              if choosing_state then 
                choose_opponent_card() 
              else
                play_selected_card()
              end
            end
            
          end
        end
      end
    else
      
      if not transition then       
        if r_b_mouse then 
          local str = "Play again"
          local h = str_height(str) 
          local w = str_width(str) + 15 
          local xr = play_x_game_over + c_wo * 6 - 15 - 15
          local yr = play_y_game_over  - 15 - 15
          
          if (in_rect(x, y, xr - w/2 , yr - h/2, w + 60, h + 60)) then
            init_transition(transition_to_1vs1)        
          
          end
        end
      end
    end 
  end
  
  if transition then
    TIME_ANIM = TIME_ANIM + dt
  end
  
end

function find_card(value, player)
  for i, c in pairs(players_hand[player]) do
    if c.value == value then return i end
  end
end
              
function end_round()
  
  ind = nil
  looser_gets_trash(turn_player)
  
  if #players_deck[get_next_player()] < 1 then
    end_game(get_next_player())
  end
  
  from_deck_to_table(1)
  from_deck_to_table(2)
  
end

function looser_gets_trash(looser)

  for i, c in pairs(trash) do
    players_deck[looser][#players_deck[looser] + 1] = c
    to_trash(trash[i])
    trash[i] = nil
  end
  
  for i, c in pairs(players_hand[(looser % 2) + 1]) do
    players_deck[looser][#players_deck[looser] + 1] = c
    to_trash(players_hand[(looser % 2) + 1][i])
    players_hand[(looser % 2) + 1][i] = nil
  end
  
  for i, c in pairs(players_hand[looser]) do
    players_deck[looser][#players_deck[looser] + 1] = c
    to_trash(players_hand[looser][i])
    players_hand[looser][i] = nil
  end
  
end

function end_game(winner)
  -- time_in_1vs1 = -.7
  sounds["card"]:stop()
  sounds["blaze"]:play()
  to_game_over = true
  -- game_over = true
  ind = nil

end

function play_selected_card()

  local c = players_hand[turn_player][ind]
  
  if not c then return end 
  
  played_a_card = false
  
  if c.value > 2 then
    played_a_card = true
  elseif c.value == 1 then
    pick_a_card(turn_player)
  else
    if #players_hand[get_next_player()] < 1 then
      played_a_card = true
    else
      choosing_state = true
    end
  end
  
  local i = #players_table[turn_player] + 1
  
  c.x = initial_pos_cards_tab[turn_player].x + (i-1) * 30 * (turn_player == 2 and 1 or -1) 
  c.y = initial_pos_cards_tab[turn_player].y
  
  players_table[turn_player][i] = c
  
  reorganise_player_hand(turn_player, ind)
  
  -- if c.value > 10 or c.value == 2 then time_in_1vs1 = -0.5 end
  
  ind = nil
end

function to_trash( card )

  card.x = trash_p.x
  card.y = trash_p.y
  table.insert(trash, card)

end

function use_card()

  local i = #players_table[turn_player]
  local c = players_table[turn_player][i]
  local np = get_next_player()
  
  -- effects
  -- 11 = blaze
  -- 12 = mirror
  -- 13 = joker
      
  if c.value == 11 then
    to_trash(players_table[np][#players_table[np]])
    to_trash(players_table[turn_player][#players_table[turn_player]])
    
    players_table[np][#players_table[np]] = nil
    players_table[turn_player][#players_table[turn_player]] = nil
    
    sounds["card"]:stop()
    sounds["blaze"]:play()
  elseif c.value == 12 then
  
    players_table[turn_player][i] = nil
    local temp = copy(players_table[np])
    players_table[np] = copy(players_table[turn_player])
    players_table[turn_player] = copy(temp)
    update_pos_cards_table()
    sounds["card"]:stop()
    sounds["mirror"]:play()
  
  elseif c.value == 13 then
    players_table[turn_player][#players_table[turn_player]].value = get_score(np) - (get_score(turn_player) - 2) + 1 
    sounds["card"]:stop()
    sounds["joker"]:play()
  end
  
  p1_score = get_score(1)
  p2_score = get_score(2)
    
end

function choose_opponent_card()
    
  choosing_state = false
  played_a_card = true
  change_card()
  pick_a_card(get_next_player())
end
  
function change_card()


  players_table[turn_player][#players_table[turn_player]].value = players_hand[get_next_player()][ind].value
  to_trash(players_hand[get_next_player()][ind])
  players_hand[get_next_player()][ind] = nil
  
  reorganise_player_hand(get_next_player(), ind)

end
    
function reorganise_player_hand(player, index)

  local nb_card_hand = #players_hand[player]  
  local index = index  
  local c = players_hand[player][ind]
  
  for i = index, nb_card_hand do
    players_hand[player][i] = players_hand[player][i + 1]
    if players_hand[player][i] then
      if player == 2 then
        players_hand[player][i].x = b_d_to_pos[player].x + 70 + i * (TRANSFORMED_CARD_WIDTH*8/10)
        players_hand[player][i].y = b_d_to_pos[player].y
      else
        players_hand[player][i].x = b_d_to_pos[player].x - 70 - i * (TRANSFORMED_CARD_WIDTH*8/10)
        players_hand[player][i].y = b_d_to_pos[player].y    
      end
    end
  end
end

function pick_card_and_play_it()
  
  local v1 = play_card(1)
  local v2 = play_card(2)

  decide_player_playing(v1, v2)

end

function play_card(player)
  
  players_table[player]= {}
  
  local c = players_deck[player][#players_deck[player]]
  
  if not c then c = generate_random_card() end
  
  local v = get_value_card(c)
  
  c.x = initial_pos_cards_tab[player].x
  c.y = initial_pos_cards_tab[player].y
  
  players_table[player][#players_table[player] + 1]  = c  
  players_deck[player][#players_deck[player]]        = nil

  return v
  
end

function generate_random_card()

  return { value = irnd(14), x = 0 , y =  0}

end

function get_value_card(card) return (card.value > 10 and 2 or card.value) end

function decide_player_playing(v1, v2)
  doing_it_again = false
  if v1 < v2 then
    turn_player = 1
  elseif v1 > v2 then
    turn_player = 2
  else
    init_pick_card()
  end

  p1_score = get_score(1) 
  p2_score = get_score(2)
  
end

function get_score(player)
  local score = 0
  for i,c in pairs(players_table[player]) do
    score = score + (c.value > 10 and 2 or c.value)
  end
  return score
end

function update_pos_cards_table()
  
  for j = 1, 2 do 
    local t = players_table[j]
    for i = 1, #players_table[j] do
      local c = players_table[j][i]
      c.x = initial_pos_cards_tab[j].x + (i-1) * 30 * (j == 2 and 1 or -1) 
      c.y = initial_pos_cards_tab[j].y
    end
  end
end

function init_pick_card()
  doing_it_again = true
  picked_card = false
  time_in_1vs1 = -1
  turn_player = 0
end

function init_transition(func)
  transition = true
  TIME_ANIM = 0
  mid_trans_call = func
end

function mid_transition()
  if mid_trans_call then mid_trans_call() end  
end

function end_transition()
  transition = false
  TIME_ANIM = 0
end

function transition_to_play()
  background = true
  menu = "play"
end

function transition_to_start()
  background = true
  menu = "start"
end

function transition_to_rules()
  background = false
  menu = "rules"
  current_tuto_page = 1
end

function transition_to_1vs1()

  if init1vs1done then return end
  background = false
  menu = "1vs1"
  init1vs1done = true
  init1vs1()
  
end


current_tuto_page = 1


tutostr = {}

table.insert(tutostr,{
  " Blaze is a card game where two players play against",
  " each other.",
  " The game ends when a player cannot play anymore.",
  " The one with the highest amount of points wins."
})

table.insert(tutostr,{
  " The blaze deck is split in half and distributed to each player",
  " They both start the game with 7 cards in hand",
  " ",
  " Players have to play one card every turn."
})

table.insert(tutostr,{
  " There is 2 types of cards : point cards and special cards.",
  " Point cards rise your point count",
  " and ",
  " Special cards have different effects"
})

table.insert(tutostr,{
  " The Blaze card destroys the",
  "  ",
  " last card the opponent have played."
})

table.insert(tutostr,{
  " The Mirror card switches the",
  "  ",
  " two players number of points."
})

table.insert(tutostr,{
  " The Joker card can get you out of ",
  "  ",
  " a pinch, eventually."
})

table.insert(tutostr,{
  " The II card lets you play one of ",
  "  ",
  " your opponent's card."
})

table.insert(tutostr,{
  " Being the first to play lets you draw a card,",
  "  ",
  " as being the target of a blaze or a II card."
})

table.insert(tutostr,{
  " If the two players have the same amount of points,",
  " they discard their played card,",
  " their points resets back to 0",
  " and draw a new one that will be played instantly."
})

table.insert(tutostr,{
  " The player with the lowest amount of point begins",
  " (special card count for 2 points).",
  " The first player to play is decided using the same technique."
})
   
table.insert(tutostr,{
  " You can go back to the main menu by clicking the",
  " arrow in the top left corner of the screen.",
  "  ",
  " Thank you for playing the game, have fun !",
  "  ",
  " Eliott"
})
    

-- DRAW STUFF
function draw_game()
  
  fill_back({.3, .2, .5})
  
  if background then
    draw_background()
  end
  
  hide_background()
  
  if menu == "start" then
      
    color(0, 0, 0)
    love.graphics.setNewFont(64)
    
    draw_menu_name("!  B L A Z E  !", GAME_WIDTH/2, 60)
    
    draw_button_centered("Play", GAME_WIDTH/2, GAME_HEIGHT /2)
    
    draw_button_centered("Rules", GAME_WIDTH/2, GAME_HEIGHT /2 + 150)
    
  end
    
  if(menu == "rules") then
  
    color(1, 1, 1) 
    for i in pairs(stars) do
      if irnd(10000) < 5 then
        love.graphics.line(stars[i].x - 3, stars[i].y - 3, stars[i].x + 3, stars[i].y + 3)
        love.graphics.line(stars[i].x - 3, stars[i].y + 3, stars[i].x + 3, stars[i].y - 3)
      end
      draw_fill_rect(stars[i].x, stars[i].y, 1, 1)
      
    end
    
    love.graphics.setNewFont(64)
    draw_menu_name("!  R U L E S  !", GAME_WIDTH/2, 60)
    
    love.graphics.setNewFont(48)
    draw_button_centered("<", 80                              , GAME_HEIGHT - 30 - str_height(">"))
    draw_button_centered(">", GAME_WIDTH - str_width(">") - 40, GAME_HEIGHT - 30 - str_height(">"))
  
    
    love.graphics.setNewFont(32)
    
    local str = tutostr[current_tuto_page]
    
    if current_tuto_page < 4 or current_tuto_page > 7 then 
      for i = 1, #str do

        color(0, 0, 0)
        draw_text(str[i], GAME_WIDTH/2 - str_width(str[i])/2 + 2 , GAME_HEIGHT/3 + str_height(">") * i + 2)  
        draw_text(str[i], GAME_WIDTH/2 - str_width(str[i])/2 + 7 , GAME_HEIGHT/3 + str_height(">") * i + 7) 
          
        color(1, 1, 1)
        draw_text(str[i], GAME_WIDTH/2 - str_width(str[i])/2 , GAME_HEIGHT/3 + str_height(">") * i) 
          
      end
      
    elseif current_tuto_page == 4 or current_tuto_page == 5 or current_tuto_page == 6 then  
      for i = 1, #str do

        color(0, 0, 0)
        draw_text(str[i], 2 + 20 , GAME_HEIGHT/3 + str_height(">") * i + 2)  
        draw_text(str[i], 7 + 20 , GAME_HEIGHT/3 + str_height(">") * i + 7) 
          
        color(1, 1, 1)
        draw_text(str[i], 20 , GAME_HEIGHT/3 + str_height(">") * i) 
        
        draw( cards[10 + current_tuto_page - 3], 
              GAME_WIDTH - TRANSFORMED_CARD_WIDTH - 200 , 
              GAME_HEIGHT/2 - TRANSFORMED_CARD_HEIGHT, 
              0, 
              RATIO_CARD_WIDTH * 2, 
              RATIO_CARD_HEIGHT * 2)
          
      end
     
    elseif current_tuto_page == 7 then  
      for i = 1, #str do

        color(0, 0, 0)
        draw_text(str[i], 2 + 20 , GAME_HEIGHT/3 + str_height(">") * i + 2)  
        draw_text(str[i], 7 + 20 , GAME_HEIGHT/3 + str_height(">") * i + 7) 
          
        color(1, 1, 1)
        draw_text(str[i], 20 , GAME_HEIGHT/3 + str_height(">") * i) 
        
        draw( cards[2], 
              GAME_WIDTH - TRANSFORMED_CARD_WIDTH - 200 , 
              GAME_HEIGHT/2 - TRANSFORMED_CARD_HEIGHT, 
              0, 
              RATIO_CARD_WIDTH * 2, 
              RATIO_CARD_HEIGHT * 2)
          
      end
     
    end
    
    
    
    local square_w = 30
    local space = 30
    local nbr_tuto = #tutostr
    
    startx = GAME_WIDTH/2 - square_w * (nbr_tuto/2) - space * (nbr_tuto - 1)/2
    
    for i = 1, nbr_tuto do 
      
      color(0, 0, 0) 
      draw_fill_rect( startx + (i-1) * (square_w + space), GAME_HEIGHT - square_w - 10 , square_w, square_w)
      
      color(1, 1, 1) 
      draw_fill_rect( startx + (i-1) * (square_w + space)+5, GAME_HEIGHT - square_w - 10 +5 , square_w -10 , square_w -10)
    
    
    end
  
    color(.7, .3, .3) 
    draw_fill_rect( startx + (current_tuto_page-1) * (square_w + space)+5, GAME_HEIGHT - square_w - 10 +5 , square_w - 10 , square_w -10)
  
  end
    
  if menu == "1vs1" then
  
   
    draw_table_blaze()
    
    color(1, 1, 1)
    -- player 1 deck 
    draw( cards[-1], 
          b_d_to_pos[1].x , 
          b_d_to_pos[1].y , 
          0, 
          RATIO_CARD_WIDTH, 
          RATIO_CARD_HEIGHT)
          
    -- player 2 deck
    draw( cards[-1], 
          b_d_to_pos[2].x , 
          b_d_to_pos[2].y , 
          0, 
          RATIO_CARD_WIDTH, 
          RATIO_CARD_HEIGHT)
    
    
    -- first player deck drawing
    for i = 1, #players_deck[1] do
    
      local c = players_deck[1][i]
      if c then
        draw( cards[0], 
              c.x , 
              c.y, 
              0, 
              RATIO_CARD_WIDTH, 
              RATIO_CARD_HEIGHT)
      end
    end
    
    -- second player deck drawing
    for i = 1, #players_deck[2] do
    
      local c = players_deck[2][i]
      
      if c then
        draw( cards[0], 
              c.x , 
              c.y, 
              0, 
              RATIO_CARD_WIDTH, 
              RATIO_CARD_HEIGHT)
      end
    end   
        
    -- score
    draw_score(1)
    draw_score(2)
    
    -- origin deck drawing
    if #blaze_deck > 0 then
      color({.3, .2, .5})
      draw_fill_rect( 
                            GAME_WIDTH/2 - str_width(" 99 ")/2, 
                            GAME_HEIGHT/2 + str_height(" 99 ") * -2,
                            str_width(" 99 "),
                            str_height(" 99 ")
      )
      draw_fill_rect( 
                            GAME_WIDTH/2 - str_width(" 99 ")/2, 
                            GAME_HEIGHT/2 + str_height(" 99 "),
                            str_width(" 99 "),
                            str_height(" 99 ")
      )      
      color({1, 1, 1})
        
      for i = 1, #blaze_deck do
      
        local c = blaze_deck[i]
        
        if c then
          draw( cards[0], 
                c.x , 
                c.y, 
                0, 
                RATIO_CARD_WIDTH, 
                RATIO_CARD_HEIGHT)
        end
      end
    end
    -- hand drawing for each player
        
    
    for i,c in pairs(players_hand[1]) do
      if not ((turn_player == 1 and not choosing_state and i == ind) or (turn_player == 2 and choosing_state and i == ind)) then
          draw( cards[c.value], 
                c.x, 
                c.y, 
                0, 
                RATIO_CARD_WIDTH, 
                RATIO_CARD_HEIGHT)
      end
    end 
    
    for i,c in pairs(players_hand[2]) do
      if not ((turn_player == 2 and not choosing_state and i == ind) or (turn_player == 1 and choosing_state and i == ind)) then
          draw( cards[c.value], 
                c.x, 
                c.y , 
                0, 
                RATIO_CARD_WIDTH, 
                RATIO_CARD_HEIGHT)
      end
    end  
    
    -- display for p2 if p2 or choosing_state and p1
    -- display for p1 if choosing_state and p2
    
    if (turn_player == 2 or (choosing_state)) and ind then
    
      p = choosing_state and get_next_player() or turn_player
      
      c = players_hand[(p)][ind]
      
      if c then
        draw( cards[c.value], 
                  c.x, 
                  c.y + 30 * (turn_player == 2 and -1 or 1) * (choosing_state and -1 or 1), 
                  0, 
                  RATIO_CARD_WIDTH, 
                  RATIO_CARD_HEIGHT)
      end
    end   
    
    for j = 1, 2 do
      
      for i,c in pairs(players_table[j]) do
        draw( cards[c.value], 
                  c.x, 
                  c.y, 
                  0, 
                  RATIO_CARD_WIDTH, 
                  RATIO_CARD_HEIGHT)
      end   
    end
      
    if game_over then
      
      color({hand_clr.r, hand_clr.g, hand_clr.b, .4 })
      draw_fill_rect(0, 0, GAME_WIDTH, GAME_HEIGHT)
    
      draw_menu_name("Game Over !", GAME_WIDTH/2, 30 + 70)
      
      if p1_score< p2_score then 
        color(.3, .8, .3)
        draw_menu_name("Y O U   W I N ! :)", GAME_WIDTH/2, GAME_HEIGHT/3 + 70, {.3, .8, .3})
      else
        color(.8, .3, .3)
        draw_menu_name("Y O U   L O O S E ! :(", GAME_WIDTH/2, GAME_HEIGHT/3  + 70, {.8, .3, .3})
      end
      
      draw_button_centered("Play again", play_x_game_over, play_y_game_over)
    end 
  
    if doing_it_again then
    
      str = "Doing it again ! "
      
      color(0, 0, 0) 
      draw_text(str, GAME_WIDTH/2 - str_width(str)/2-2, GAME_HEIGHT/2 - str_height(str)/2-2)
      draw_text(str, GAME_WIDTH/2 - str_width(str)/2-2, GAME_HEIGHT/2 - str_height(str)/2+2)
      
      draw_text(str, GAME_WIDTH/2 - str_width(str)/2+2, GAME_HEIGHT/2 - str_height(str)/2-2)
      draw_text(str, GAME_WIDTH/2 - str_width(str)/2+2, GAME_HEIGHT/2 - str_height(str)/2+2)
      
      color(.6, 0.2, .2) 
      draw_text(str, GAME_WIDTH/2 - str_width(str)/2, GAME_HEIGHT/2 - str_height(str)/2)
    end 
    
    if message and message ~="" then
      local xr = GAME_WIDTH/2
      local yr = GAME_HEIGHT - 100
      color(0, 0, 0, .85)
      
      draw_fill_rect(xr - str_width(message)/2 - 15 ,yr - str_height(message)/2 - 15, str_width(message) + 30, str_height(message) + 30 )
      
      
      color(1, 1, 1, 1) 
      draw_menu_name(message, GAME_WIDTH/2, GAME_HEIGHT - 100)
    
    end
    
    
  end

  color(1, 1, 1) 
  
  -- back arrow to go one menu above
  if not (menu == "start") then 
    
    color(1, 1, 1, 1 / (hover_back_arrow and 1 or 2))
    draw(back, barrowx + cos(writing_offset_timer * 5) * 4, barrowy) 
  end
  
  color(1, 1, 1) 
  if transition then
    for i = 1, 10 do  
      for j = 1, 10 do
        
        local minij =  math.min(i,j) -- square advancement 
                
        local ratio = -math.sin(-3.2 + (TIME_ANIM * 1.2- minij/10))*1.03
        
        -- ratio is * 1.3 for it to be out of bound and cover the entire screen even with a wave
        -- sin (-3.2) is for starting with a few seconds of the old screen still visible

        -- negative width draws the rect so we want to keep it a 0 if its intended to be negative
        local wsize = math.max((GAME_WIDTH  / 10) * ratio, 0)
        local hsize = math.max((GAME_HEIGHT / 10) * ratio, 0)
        
        -- if last rect is full (ratio > 1) then transition to other menu
        if j == 10 and i == 10 and ratio > 0.90 then mid_transition() end
        if TIME_ANIM > 3.5 then end_transition() end
                  
        -- with a rect
        -- draw_fill_rect( (i - .5) * GAME_WIDTH /10 -wsize / 2, 
                        -- (j - .5) * GAME_HEIGHT/10 -hsize / 2, 
                        -- wsize,
                        -- hsize
        -- )
        -- with an image
        local img = cut_trs_img[(j-1)*10 + i ]
        
        draw(img,
              (i - .5) * GAME_WIDTH /10 -wsize / 2, 
              (j - .5) * GAME_HEIGHT/10 -hsize / 2,
              0,
              wsize / img:getWidth( ) ,
              hsize / img:getHeight( )
             )
      end
    end
  end 
  
end

function draw_menu_name(str, x , y, col)
    
  local col = col or {1, 1, 1}
  local str_w = str_width(str)
  local str_h = str_height(str)
  
  for i = 1, 5 do  
    local x = x + cos(writing_offset_timer  + i / 10) * 20
    local y = y + sin(writing_offset_timer*2  + i / 10) * 20
    local angle = cos(writing_offset_timer  + i / 15) * .17
    
    color({0, 0, 0, .3})
    draw_text(str, x + 20,  y + 20, angle, 1, 1, str_w / 2, str_h / 2 )
  end
  
  for i = 1, 4 do      
    local x = x + cos(writing_offset_timer  + i / 10) * 20
    local y = y + sin(writing_offset_timer*2  + i / 10) * 20
    local angle = cos(writing_offset_timer  + i / 15) * .17
    
    color({col[1] * i/5, col[2] * i/5, col[3] * i/5})
    draw_text(str, x,  y, angle, 1, 1, str_w / 2, str_h / 2 )
  end
  
  local x = x + cos(writing_offset_timer  + 5 / 10) * 20
  local y = y + sin(writing_offset_timer*2  + 5 / 10) * 20
  local angle = cos(writing_offset_timer  + 5 / 15) * .17
  
  color(col)
  draw_text(str, x,  y, angle, 1, 1, str_w / 2, str_h / 2 )
  
end 

function draw_rect_with_border( x, y, w, h, border, col)
  col = col or {1, 1, 1}
  border = border or 1
  x = x or 1
  y = y or 1
  w = w or 1
  h = h or 1
  
  color(col)
  
  draw_fill_rect(x + border, y, w - border*2, border)
  draw_fill_rect(x, y, border, h)
  
  draw_fill_rect(x + w, y + h, -border, -h)
  draw_fill_rect(x + w- border, y + h, -w + border*2, -border)

end

function draw_button_centered(str, x ,y ,w, h, c)
  
  if not str or (not x and not y)  then return end
    
  love.graphics.setNewFont(48)
  
  h = h or str_height(str) 
  w = w or str_width(str) + 15
  c = c or {1, 1, 1}
  
  color(c)
  
  local xm, ym = get_mouse_pos() -- get the position of the mouse 
  if transition then xm = -1 ym = -1 end
  
  local x = x - w/2 - 15 + c_wo * 6  
  local y = y - h/2 - 15  
  
  local hover = false
  
  if(in_rect(xm, ym, x-15, y-15, w + 30 + 30 - c_wo * 6, h + 30 + 30)) then hover = true end
  
  local c1 =     hover and {.6, .6, 1, .8} or {0, 0, 0, .8}  
  local c2 = not hover and {1, 1, 1, .8} or {0, 0, 0, .8} 
  
  draw_rect_with_border(  x-15,
                          y-15,
                          30 + w + 30,
                          30 + h + 30,
                          15,
                          c2
  )
  
  draw_rect_with_border(  x,
                          y,
                          30 + w,
                          30 + h,
                          15,
                          c1
  )
  
  color(0, 0, 0)
  draw_text(  str,
              x + 7.5 + w / 2 + 15 + 5,
              y + h / 2 + 15 + 5,
              c_wo/20,
              1,
              1,
              w / 2,
              h / 2
              )
              
  color(1, 1, 1, 1)
  draw_text(  str,
              x + 7.5 + w / 2 + 15,
              y + h / 2 + 15,
              c_wo/20,
              1,
              1,
              w / 2,
              h / 2
              )
end

function draw_button_centered_red(str, x ,y ,w, h, c)
  
  if not str or (not x and not y)  then return end
    
  love.graphics.setNewFont(48)
  
  h = h or str_height(str) 
  w = w or str_width(str) + 15
  c = c or {1, 1, 1}
  
  color(c)
  
  local xm, ym = get_mouse_pos() -- get the position of the mouse 
  
  local x = x - w/2 - 15 + c_wo * 6  
  local y = y - h/2 - 15  
    
  local c1 = {.5, 0, 0}  
  local c2 = {1, .3, .3}
  
  draw_rect_with_border(  x-15,
                          y-15,
                          30 + w + 30,
                          30 + h + 30,
                          15,
                          c2
  )
  
  draw_rect_with_border(  x,
                          y,
                          30 + w,
                          30 + h,
                          15,
                          c1
  )
  
  color(.5, 0, 0, 1)
  draw_text(  str,
              x + 7.5 + w / 2 + 15 + 5,
              y + h / 2 + 15 + 5,
              c_wo/20,
              1,
              1,
              w / 2,
              h / 2
              )
              
  color(1, .3, .3)
  draw_text(  str,
              x + 7.5 + w / 2 + 15,
              y + h / 2 + 15,
              c_wo/20,
              1,
              1,
              w / 2,
              h / 2
              )
end

function fill_back(c, w, h)
  w = w or GAME_WIDTH
  h = h or GAME_HEIGHT
  color(c)
  draw_fill_rect(0, 0, w, h)
end

function draw_score(player)

  str = (player == 1 and p1_score or p2_score)
  
  draw_text(str, GAME_WIDTH/2 - str_width(str) / 2, GAME_HEIGHT/2 + str_height(str) * (player == 1 and -2 or 1)  )

end

function draw_table_blaze()

  love.graphics.setNewFont(48)
-- WHITE RECTANGLE AROUND
  draw_rect_with_border( 0, 0, 1000, 600, 10, {1, 1, 1})
  
  if #blaze_deck<1 then
    for i in pairs(stars) do
      if irnd(10000) < 5 then
        love.graphics.line(stars[i].x - 3, stars[i].y - 3, stars[i].x + 3, stars[i].y + 3)
        love.graphics.line(stars[i].x - 3, stars[i].y + 3, stars[i].x + 3, stars[i].y - 3)
      end
      draw_fill_rect(stars[i].x, stars[i].y, 1, 1)
      
    end

  end
-- players deck
  draw_rect_with_border( b_d_to_pos[1].x - 6 , b_d_to_pos[1].y - 6, TRANSFORMED_CARD_WIDTH + 12, TRANSFORMED_CARD_HEIGHT + 12, 4, {.3, .3, .6})
  draw_rect_with_border( b_d_to_pos[2].x - 6 , b_d_to_pos[2].y - 6, TRANSFORMED_CARD_WIDTH + 12, TRANSFORMED_CARD_HEIGHT + 12, 4, {.3, .3, .6})
  
-- players hand
  
-- hand_clr
  local rn = irnd(0,100)
  if(rn < 34)     then hand_clr.r = .5 + (hand_clr.r - .018 +  rn    /800)%(0.5)
  elseif(rn > 66) then hand_clr.g = .5 + (hand_clr.g - .018 + (rn-66)/800)%(0.5)
  else                 hand_clr.b = .5 + (hand_clr.b - .018 + (rn-33)/800)%(0.5) end
  
--outer      
  draw_rect_with_border( b_d_to_pos[1].x - 8 - 35                            , b_d_to_pos[1].y - 6 , -8 * TRANSFORMED_CARD_WIDTH*8/10 + 12 - 73, TRANSFORMED_CARD_HEIGHT + 12, 4, {hand_clr.r, hand_clr.g, hand_clr.b})
  draw_rect_with_border( b_d_to_pos[2].x - 8 + 45 + TRANSFORMED_CARD_WIDTH +5, b_d_to_pos[2].y - 6 ,  8 * TRANSFORMED_CARD_WIDTH*8/10 + 12 + 62, TRANSFORMED_CARD_HEIGHT + 12, 4, {hand_clr.r, hand_clr.g, hand_clr.b})
  
--inner      
  color(hand_clr.r, hand_clr.g, hand_clr.b, .5)
  
  draw_fill_rect( b_d_to_pos[1].x - 4 - 35, 
                  b_d_to_pos[1].y - 2 , 
                  -8 * TRANSFORMED_CARD_WIDTH*8/10 + 4 - 73,
                  TRANSFORMED_CARD_HEIGHT + 4
  )

  draw_fill_rect( b_d_to_pos[2].x - 4 + 41 + TRANSFORMED_CARD_WIDTH +5,
                  b_d_to_pos[2].y - 2 , 
                  8 * TRANSFORMED_CARD_WIDTH*8/10 + 12 + 62 , 
                  TRANSFORMED_CARD_HEIGHT + 4 
  )
  
-- table center
  
  local cp1 = {.3, .3, .6}
  local cp2 = {.3, .3, .6}
  
  
  if p2_score < p1_score then
    cp1 = {.3, .45, .3}
    cp2 = {.45, .3, .3}
  elseif p1_score < p2_score then
    cp1 = {.45, .3, .3}
    cp2 = {.3, .45, .3}
  end
  
  love.graphics.setNewFont(64)
  vertical_write_funny("BLAZE", 60, 20, cp1)
  vertical_write_funny("BLAZE", GAME_WIDTH - 62 - str_width("9"), GAME_HEIGHT - str_height("9") * 5 - 40, cp2)
  
  love.graphics.setNewFont(48)
  
  color(cp1)
  draw_fill_rect( 
                        GAME_WIDTH/2 - str_width(" 99 ")/2, 
                        GAME_HEIGHT/2 + str_height(" 99 ") * -2,
                        str_width(" 99 "),
                        str_height(" 99 ")
  )
  
  color(cp2)
  draw_fill_rect( 
                        GAME_WIDTH/2 - str_width(" 99 ")/2, 
                        GAME_HEIGHT/2 + str_height(" 99 "),
                        str_width(" 99 "),
                        str_height(" 99 ")
  )     
  
  color({1, 1, 1})
  draw_rect_with_border( 
                        GAME_WIDTH/2 - str_width(" 99 ")/2, 
                        GAME_HEIGHT/2 + str_height(" 99 ") * -2,
                        str_width(" 99 "),
                        str_height(" 99 "),
                        4,
                        {.5, .5, .5}
  )
  draw_rect_with_border( 
                        GAME_WIDTH/2 - str_width(" 99 ")/2, 
                        GAME_HEIGHT/2 + str_height(" 99 "),
                        str_width(" 99 "),
                        str_height(" 99 "),
                        4,
                        {.5, .5, .5}
  )      
  color({1, 1, 1})
  color({0, 0, 0})
  
  local rt = 7 / 10
  
  for y = -3, 2 do 
    love.graphics.line(GAME_WIDTH/2 - 100 * rt, GAME_HEIGHT/2 + 60 * rt + y, GAME_WIDTH/2 + 100 * rt, GAME_HEIGHT/2 - 60 * rt + y)
    
    love.graphics.line(GAME_WIDTH/2 - 100 * rt, GAME_HEIGHT/2 + 60 * rt + y, GAME_WIDTH/2 - 300 * rt, GAME_HEIGHT/2 + 60 * rt + y)
    
    love.graphics.line(GAME_WIDTH/2 + 300 * rt, GAME_HEIGHT/2 - 60 * rt + y, GAME_WIDTH/2 + 100 * rt, GAME_HEIGHT/2 - 60 * rt + y)
  end
  
  love.graphics.setNewFont(32)
  str = "  MY TURN"
  
  buttonx = 180 + cos(writing_offset_timer/3) * 5
  buttony = 370 + sin(writing_offset_timer) * 2.5
  
  radius = 25
  color({0, 0, 0})
  love.graphics.circle("fill", buttonx + radius, buttony + radius, radius)
  
  if turn_player == 2 then 
    color({0.8, 0.3, 0.3, .3})
    love.graphics.circle("fill", buttonx + radius, buttony + radius, radius +5)
    color({0.8, 0.3, 0.3})
  
  else
    color({.3, 0.1, 0.1})
  
  end
  
  color(turn_player == 2 and {0.8, 0.3, 0.3} or {.3, 0.1, 0.1})
  love.graphics.circle("fill", buttonx + radius, buttony + radius, radius - 5)
  
  color({0, 0, 0})
  draw_text(str, buttonx + radius*2 + 10, buttony + 5)
  love.graphics.setNewFont(48)
  
end
    


-- MISC
function in_rect(x, y, xr, yr, wr, hr)

  return (x>xr) and (y > yr) and (x < xr + wr) and (y < yr + hr)

end

function init1vs1()

  init1vs1done = false
  hand_picked_done = false
  to_game_over = false
  game_over = false
  distribution_of_cards = false
  deck_anim_ended = false
  played_a_card = false
  picked_card = false
  choosing_state = false
  
  time_in_1vs1 = -0.5
  to_player = 0
  blaze_deck = {}
  move_angle_card = 0
  my_player = 2
  turn_player = 0
  p1_score = 0
  p2_score = 0
  
  card = {x = 0, y = 0}
  players_deck  = { [1] = {}, [2] = {} }
  players_hand  = { [1] = {}, [2] = {} }
  b_d_to_pos = { [1] = {},
                 [2] = {}}
  players_table = { [1] = {}, [2] = {} }
  initial_pos_cards_tab = { [1] = {}, [2] = {} }
  
  blaze_deck = create_blaze_deck()
  
  b_d_to_pos = { [1] = {x = GAME_WIDTH - TRANSFORMED_CARD_WIDTH - 25, y = 25 }, [2] = {x = 25 , y = GAME_HEIGHT - TRANSFORMED_CARD_HEIGHT - 25}}
  

  initial_pos_cards_tab = { [1] = {x = GAME_WIDTH/2 - TRANSFORMED_CARD_WIDTH/2 - 120, y =  GAME_HEIGHT/2 - TRANSFORMED_CARD_HEIGHT/2 - 47},
                            [2] = {x = GAME_WIDTH/2 - TRANSFORMED_CARD_WIDTH/2 + 120, y =  GAME_HEIGHT/2 - TRANSFORMED_CARD_HEIGHT/2 + 47 }
                          }
                          
  deck_anim_ended = false
  
  
end

function create_blaze_deck()
  total_card = 0
  pattern_deck = {[1] = 1,
                  [2] = 8,
                  [3] = 6,
                  [4] = 6,
                  [5] = 5,
                  [6] = 5,
                  [7] = 2,
                  [8] = 2,
                  -- [9] = 1,
                  -- [10] = 1,
                  [11] = 3,
                  [12] = 3,
                  [13] = 3
                 }                
   
  deck = {}
  
  for i, p in pairs(pattern_deck) do
    total_card = total_card + p
  end
  local count = 0
  for i, p in pairs(pattern_deck) do
    for j = 1, p do
      deck[total_card - count] = { value = i, x = GAME_WIDTH/2 - TRANSFORMED_CARD_WIDTH/2 , y =  GAME_HEIGHT/2 - TRANSFORMED_CARD_HEIGHT/2 - count / 3 }
      count = count + 1
    end
  end
  -- total_card = #deck
  shuffle(deck)
  return deck
  
end
  
function choose_new_card_to_move()
  sounds["card"]:stop()
  sounds["card"]:play()
  local player_d1 = players_deck[to_player] or {}
  
  to_player = (to_player % 2) + 1

  local player_d2 = players_deck[to_player]
    
  if to_player == 1 then  
    to_pos = { x = b_d_to_pos[to_player].x + (#player_d2 - 1)/2,
               y = b_d_to_pos[to_player].y - (#player_d2 - 1)/2
             }
  else
    to_pos = { x = b_d_to_pos[to_player].x - (#player_d2 - 1)/2,
               y = b_d_to_pos[to_player].y - (#player_d2 - 1)/2
             }
  end
  
  card = blaze_deck[ total_card - #player_d1 - #player_d2]  
  
  angle = math.angle(card.x, card.y, to_pos.x ,to_pos.y )
  
end

function get_next_player()
  return (turn_player % 2) + 1
end

function send_card_to_deck_of_player(to_player)

  local player_d = players_deck[to_player]  
  player_d[#player_d + 1] = blaze_deck[#blaze_deck]  
  blaze_deck[#blaze_deck] = nil

end

NUM_CARD_BEGINNING = 7

function from_deck_to_table(player)

  pick_a_card(player, NUM_CARD_BEGINNING)

end

function pick_a_card(player, nb_card)

  nb_card = nb_card or 1
  if players_deck[player] and #players_deck[player] > 0 then
    for i = 1, min(nb_card, #players_deck[player]) do
    
      local l = #players_hand[player] +  1
      
      -- pick card from deck
      
      local c = pick(players_deck[player])
      
      
      -- change coordinates
      
      if player == 2 then
        c.x = b_d_to_pos[player].x + 70 + l * (TRANSFORMED_CARD_WIDTH*8/10)
        c.y = b_d_to_pos[player].y
      else
        c.x = b_d_to_pos[player].x - 70 - l * (TRANSFORMED_CARD_WIDTH*8/10)
        c.y = b_d_to_pos[player].y    
      end
      
      -- put it in hand
      
      table.insert(players_hand[player], c)
      
    end
  end
end

function pick(hand)

  local card = hand[#hand]
  hand[#hand] = nil
  
  return card
end

function shuffle(deck)

  for i = 1, (#deck * 2) do
  
    local i1 = irnd(0,#deck-1) + 1
    local i2 = irnd(0,#deck-1) + 1
    
    local temp = deck[i1].value
    deck[i1].value = deck[i2].value
    deck[i2].value = temp
  end
  
end

played_sound = false

function mouse_pos_to_card_on_screen(x, y)
  
  for i,c in pairs(players_hand[(choosing_state and get_next_player() or turn_player)]) do
  
    if x > c.x then
      if x < c.x + TRANSFORMED_CARD_WIDTH then
        if y > c.y then
          if y < c.y + TRANSFORMED_CARD_HEIGHT + 30 * (turn_player == 2 and -1 or 1) then
            if not played_sound or ind ~= i then
              sounds["select"]:stop()
              sounds["select"]:play()
              played_sound = true
            end
            return i
          end
        end
      end
    end
    
  end
  
  played_sound = false
end
