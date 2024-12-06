io.stdout:setvbuf("no")

-- RP Mini, Odin 2
--btn_i_START = 7
--btn_i_RED = 3
--btn_i_GREEN = 4
--btn_i_BLUE = 1
--btn_i_YELLOW = 2

-- 8bitdo
btn_i_START = 8
btn_i_RED = 4
btn_i_GREEN = 3
btn_i_BLUE = 2
btn_i_YELLOW = 1

win_dx = 640
win_dy = 480

btn_start = false
btn_MEM = 0

ST = 1
ST01_LOST = 1
ST02_DISP_NEXT_COLOR = 2
ST03_CHK_DISP_COLOR_INDEX = 3
ST04_GET_NEXT_COLOR_BTN_PRESS = 4
ST05_WAIT_FOR_COLOR_BTN_RLS = 5
ST06_CHECK_COLOR_BTN_INDEX = 6
ST07_ROUND_WON = 7
ST08_GAME_LOST = 8

btns = {}
COLOR_RED = 1
COLOR_GREEN = 2
COLOR_BLUE = 3
COLOR_YELLOW = 4

tmr_color_on_PRE = 1.0
tmr_color_off_PRE = 0.25
tmr_ACC = 0.0
color_i = 1
colors = {}

----------
-- LOAD --
----------
function love.load()
  -- init application
	love.window.setTitle("Simon")
	love.window.setMode(400, 400)
  local safeX, safeY, safeW, safeH = love.window.getSafeArea()
	love.graphics.translate(safeX, safeY)

  -- init red button
  init_button(1.0, 0.0, 0.0, 50.0, (safeW / 2), (safeH / 2) - 100, false)
  -- init green button
  init_button(0.0, 1.0, 0.0, 50.0, (safeW / 2) - 100, (safeH / 2), false)
  -- init blue button
  init_button(0.0, 0.0, 1.0, 50.0, (safeW / 2) + 100, (safeH / 2), false)
  -- init yellow button
  init_button(1.0, 1.0, 0.0, 50.0, (safeW / 2), (safeH / 2) + 100, false)
  -- init random color table
  for i=1,999 do
    table.insert(colors, 1)
  end
  -- init audio
  sound_1 = love.audio.newSource("assets/guitar-c.wav", "static")
  sound_2 = love.audio.newSource("assets/guitar-d.wav", "static")
  sound_3 = love.audio.newSource("assets/guitar-d-sharp.wav", "static")
  sound_4 = love.audio.newSource("assets/guitar-g.wav", "static")
end

function init_button(red, green, blue, r, x, y, pressed)
  btn = {}
  btn.red = red
  btn.green = green
  btn.blue = blue
  btn.r = r
  btn.x = x
  btn.y = y
  btn.pressed = pressed
  table.insert(btns, btn)
end

------------
-- UPDATE --
------------
function love.update(dt)
	-- get joystick input
	local joysticks = love.joystick.getJoysticks()
	if #joysticks > 0 then
		btns[COLOR_YELLOW].pressed = joysticks[1]:isDown(btn_i_YELLOW)
		btns[COLOR_BLUE].pressed = joysticks[1]:isDown(btn_i_BLUE)
		btns[COLOR_GREEN].pressed = joysticks[1]:isDown(btn_i_GREEN)
		btns[COLOR_RED].pressed = joysticks[1]:isDown(btn_i_RED)
		btn_start = joysticks[1]:isDown(btn_i_START)
	end
  -- get keyboard input
  btns[COLOR_YELLOW].pressed = btns[COLOR_YELLOW].pressed or love.keyboard.isDown("down")
  btns[COLOR_BLUE].pressed = btns[COLOR_BLUE].pressed or love.keyboard.isDown("right")
  btns[COLOR_GREEN].pressed = btns[COLOR_GREEN].pressed or love.keyboard.isDown("left")
  btns[COLOR_RED].pressed = btns[COLOR_RED].pressed or love.keyboard.isDown("up")
  btn_start = btn_start or love.keyboard.isDown("return")
  -- get mouse input
  if love.mouse.isDown(1) then
    local m_x = love.mouse.getX()
    local m_y = love.mouse.getY()
    -- start
    btn_start = btn_start or (m_y < (btns[COLOR_RED].y - btns[COLOR_RED].r / 2))
    -- red
    btns[COLOR_RED].pressed = btns[COLOR_RED].pressed or 
    (m_x > (btns[COLOR_RED].x - btns[COLOR_RED].r / 2) and m_x < (btns[COLOR_RED].x + btns[COLOR_RED].r / 2) and
    m_y > (btns[COLOR_RED].y - btns[COLOR_RED].r / 2) and m_y < (btns[COLOR_RED].y + btns[COLOR_RED].r / 2))
    -- green
    btns[COLOR_GREEN].pressed = btns[COLOR_GREEN].pressed or 
    (m_x > (btns[COLOR_GREEN].x - btns[COLOR_GREEN].r / 2) and m_x < (btns[COLOR_GREEN].x + btns[COLOR_GREEN].r / 2) and
    m_y > (btns[COLOR_GREEN].y - btns[COLOR_GREEN].r / 2) and m_y < (btns[COLOR_GREEN].y + btns[COLOR_GREEN].r / 2))
    -- blue
    btns[COLOR_BLUE].pressed = btns[COLOR_BLUE].pressed or 
    (m_x > (btns[COLOR_BLUE].x - btns[COLOR_BLUE].r / 2) and m_x < (btns[COLOR_BLUE].x + btns[COLOR_BLUE].r / 2) and
    m_y > (btns[COLOR_BLUE].y - btns[COLOR_BLUE].r / 2) and m_y < (btns[COLOR_BLUE].y + btns[COLOR_BLUE].r / 2))
    -- yellow
    btns[COLOR_YELLOW].pressed = btns[COLOR_YELLOW].pressed or 
    (m_x > (btns[COLOR_YELLOW].x - btns[COLOR_YELLOW].r / 2) and m_x < (btns[COLOR_YELLOW].x + btns[COLOR_YELLOW].r / 2) and
    m_y > (btns[COLOR_YELLOW].y - btns[COLOR_YELLOW].r / 2) and m_y < (btns[COLOR_YELLOW].y + btns[COLOR_YELLOW].r / 2))
  end
	-- ST01_LOST --
	if ST == ST01_LOST then
		if btn_start then
      new_state(ST02_DISP_NEXT_COLOR)
		end
  -- ST02_DISP_NEXT_COLOR --  
	elseif ST == ST02_DISP_NEXT_COLOR then
    tmr_ACC = tmr_ACC + dt
    -- print("tmr_ACC: " .. tmr_ACC)
    if tmr_ACC >= tmr_color_on_PRE then
      new_state(ST03_CHK_DISP_COLOR_INDEX)
    end
	-- ST03_CHK_DISP_COLOR_INDEX --
  elseif ST == ST03_CHK_DISP_COLOR_INDEX then
    tmr_ACC = tmr_ACC + dt
    if tmr_ACC >= tmr_color_off_PRE then
      if color_i < #colors then
        new_state(ST02_DISP_NEXT_COLOR)
      else
        new_state(ST04_GET_NEXT_COLOR_BTN_PRESS)
      end
    end
	-- ST04_GET_NEXT_COLOR_BTN_PRESS --
  elseif ST == ST04_GET_NEXT_COLOR_BTN_PRESS then
    btn_MEM = 0
    if btns[COLOR_BLUE].pressed then 
      btn_MEM = 3
    elseif btns[COLOR_YELLOW].pressed then
      btn_MEM = 4
    elseif btns[COLOR_RED].pressed then
      btn_MEM = 1
    elseif btns[COLOR_GREEN].pressed then
      btn_MEM = 2
    end
    if btn_MEM > 0 then
      new_state(ST05_WAIT_FOR_COLOR_BTN_RLS)
    end
	-- ST05_WAIT_FOR_COLOR_BTN_RLS --
  elseif ST == ST05_WAIT_FOR_COLOR_BTN_RLS then
    if not btns[COLOR_BLUE].pressed and not btns[COLOR_YELLOW].pressed and not btns[COLOR_RED].pressed and not btns[COLOR_GREEN].pressed then
      tmr_ACC = tmr_ACC + dt
      -- print("  btn_MEM: " .. btn_MEM)
      -- print("  color_i: " .. color_i)
      -- print("  colors[color_i]: " .. colors[color_i])
      if btn_MEM == colors[color_i] then
        if color_i < #colors then 
          if tmr_ACC > 0.1 then
            new_state(ST04_GET_NEXT_COLOR_BTN_PRESS)
          end
        else 
          if tmr_ACC > 0.5 then
            new_state(ST02_DISP_NEXT_COLOR)
          end
        end
      else
        new_state(ST08_GAME_LOST)
      end
    else
      tmr_ACC = 0
    end
	elseif ST == ST06_CHECK_COLOR_BTN_INDEX then
	elseif ST == ST07_ROUND_WON then
	elseif ST == ST08_GAME_LOST then
    tmr_ACC = tmr_ACC + dt
    if tmr_ACC > 1.0 then
      new_state(ST01_LOST)
    end
	end

end

function new_state(NST)
	if NST == ST01_LOST then
    print("ST01_LOST")
	elseif NST == ST02_DISP_NEXT_COLOR then
    print("ST02_DISP_NEXT_COLOR")
    if ST == ST01_LOST then
      -- init vars
      tmr_color_on_PRE = 1.0
      tmr_color_off_PRE = 0.25
      color_i = 1
      tmr_ACC = 0 
      -- randomize color list
      love.math.setRandomSeed(love.timer.getTime())
      colors = {}
      table.insert(colors, rand())
      print("colors[1]: " .. colors[1])
    elseif ST == ST03_CHK_DISP_COLOR_INDEX then
      color_i = color_i + 1
      tmr_ACC = 0
    elseif ST == ST05_WAIT_FOR_COLOR_BTN_RLS then
      color_i = 1
      table.insert(colors, rand())
      tmr_color_on_PRE = 0.9 * tmr_color_on_PRE
      tmr_color_off_PRE = 0.9 * tmr_color_off_PRE
    end
  elseif NST == ST03_CHK_DISP_COLOR_INDEX then
    print("ST03_CHK_DISP_COLOR_INDEX")
    ST = ST03_CHK_DISP_COLOR_INDEX
    tmr_ACC = 0
  elseif NST == ST04_GET_NEXT_COLOR_BTN_PRESS then
    print("ST04_GET_NEXT_COLOR_BTN_PRESS")
    if ST == ST03_CHK_DISP_COLOR_INDEX then
      color_i = 1
      btn_MEM = 0
    elseif ST == ST05_WAIT_FOR_COLOR_BTN_RLS then
      color_i = color_i + 1
    end
  elseif NST == ST05_WAIT_FOR_COLOR_BTN_RLS then
    print("ST05_WAIT_FOR_COLOR_BTN_RLS")
  elseif NST == ST06_CHECK_COLOR_BTN_INDEX then
    print("ST06_CHECK_COLOR_BTN_INDEX")
  elseif NST == ST07_ROUND_WON then
    print("ST07_ROUND_WON")
  elseif NST == ST08_GAME_LOST then
    print("ST08_GAME_LOST")
	end
  -- reset state time
  tmr_ACC = 0
  -- update state
  ST = NST
end

-- return random number between 1 and 4
function rand()
  return math.floor(love.timer.getTime() * (10^6)) % 4 + 1
end

----------
-- DRAW --
----------
function love.draw()
	--draw red, green, blue and yellow buttons; pressed or not pressed
  if ST == ST01_LOST or ST == ST04_GET_NEXT_COLOR_BTN_PRESS or ST == ST05_WAIT_FOR_COLOR_BTN_RLS then
    draw_button(COLOR_RED, btns[COLOR_RED].pressed)
    draw_button(COLOR_GREEN, btns[COLOR_GREEN].pressed)
    draw_button(COLOR_BLUE, btns[COLOR_BLUE].pressed)
    draw_button(COLOR_YELLOW, btns[COLOR_YELLOW].pressed)
    -- play sound
    if btns[COLOR_RED].pressed then
      if not sound_1:isPlaying() then
        -- print("play sound 1")
        love.audio.play(sound_1)
      end
    elseif btns[COLOR_GREEN].pressed then
      if not sound_2:isPlaying() then
        -- print("play sound 2")
        love.audio.play(sound_2)
      end
    elseif btns[COLOR_BLUE].pressed then
      if not sound_3:isPlaying() then
        -- print("play sound 3")
        love.audio.play(sound_3)
      end
    elseif btns[COLOR_YELLOW].pressed then
      if not sound_4:isPlaying() then
        -- print("play sound 4")
        love.audio.play(sound_4)
      end
    else
      -- print("stop playing sound")
      love.audio.stop()
    end
  elseif ST == ST02_DISP_NEXT_COLOR then
    if colors[color_i] == COLOR_RED then
      draw_button(COLOR_RED,    true)
      draw_button(COLOR_GREEN,  false)
      draw_button(COLOR_BLUE,   false)
      draw_button(COLOR_YELLOW, false)
      -- play audio
      if not sound_1:isPlaying( ) then
        -- print("play sound 1")
        love.audio.play(sound_1)
      end
    elseif colors[color_i] == COLOR_GREEN then
      draw_button(COLOR_RED,    false)
      draw_button(COLOR_GREEN,  true)
      draw_button(COLOR_BLUE,   false)
      draw_button(COLOR_YELLOW, false)
      -- play audio
      if not sound_2:isPlaying( ) then
        -- print("play sound 2")
        love.audio.play(sound_2)
      end
    elseif colors[color_i] == COLOR_BLUE then
      draw_button(COLOR_RED,    false)
      draw_button(COLOR_GREEN,  false)
      draw_button(COLOR_BLUE,   true)
      draw_button(COLOR_YELLOW, false)
      -- play audio
      if not sound_3:isPlaying( ) then
        -- print("play sound 3")
        love.audio.play(sound_3)
      end
    elseif colors[color_i] == COLOR_YELLOW then
      draw_button(COLOR_RED,    false)
      draw_button(COLOR_GREEN,  false)
      draw_button(COLOR_BLUE,   false)
      draw_button(COLOR_YELLOW, true)
      -- play audio
      if not sound_4:isPlaying( ) then
        -- print("play sound 4")
        love.audio.play(sound_4)
      end
    end
  else
    draw_button(COLOR_RED,    false)
    draw_button(COLOR_GREEN,  false)
    draw_button(COLOR_BLUE,   false)
    draw_button(COLOR_YELLOW, false)
    -- stop audio
    -- print("stop playing sound")
    love.audio.stop()
  end
  
  -- prompt user
  love.graphics.setColor(1, 1, 1)
  if ST == ST01_LOST then
    love.graphics.print("Press Start", 10, 10)
  elseif ST == ST02_DISP_NEXT_COLOR or ST == ST03_CHK_DISP_COLOR_INDEX then
    love.graphics.print("Displaying Sequence", 10, 10)
  elseif ST == ST04_GET_NEXT_COLOR_BTN_PRESS or ST == ST05_WAIT_FOR_COLOR_BTN_RLS then
    love.graphics.print("Enter Sequence", 10, 10)
  elseif ST == ST08_GAME_LOST then
    love.graphics.print("Game Over!", 10, 10)
  end

end

function draw_button(color, pressed)
	--draw button and button shadow
  btns[color].pressed = pressed
	if(pressed) then
    print("color pressed: " .. color)
		love.graphics.setColor(btns[color].red, btns[color].green, btns[color].blue)
		love.graphics.circle("fill", btns[color].x, btns[color].y, btns[color].r)
	else
		love.graphics.setColor(btns[color].red*0.5, btns[color].green*0.5, btns[color].blue*0.5)
		love.graphics.circle("fill", btns[color].x, btns[color].y, btns[color].r)
		love.graphics.setColor(btns[color].red*0.75, btns[color].green*0.75, btns[color].blue*0.75)
		love.graphics.circle("fill", btns[color].x-5, btns[color].y-5, btns[color].r)
	end
end