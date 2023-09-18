


-- Importing Class Library for OOPS
Class = require 'class'

-- Importing PUSH Library
push = require 'push'

require 'Paddle'
require 'Ball'

-- Constants
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

-- Objects to store paddle positions
paddle1 = Paddle(5, 30, 5, 30)
paddle2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 40, 5, 30)

ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 5, 5)

player1Score = 0
player2Score = 0
serving = math.random(2) == 1 and 1 or 2

winning = 0
if serving == 1 then 
    ball.dx = 100
else 
    ball.dx = -100

end


gameState = 'start'

-- Load function
function love.load()
    math.randomseed(os.time())

    -- Font and Texture
    love.graphics.setDefaultFilter('nearest', 'nearest') -- Texture Scaling
    smallFont = love.graphics.newFont('retro.ttf', 10)
    scoreFont = love.graphics.newFont('retro.ttf', 32)
    

    -- Loading Audio

    sounds = {
        ['paddle_hit'] = love.audio.newSource('Paddle.wav' , 'static'),
        ['points_scored'] = love.audio.newSource('Points.wav' , 'static'),
        ['wall_hit'] = love.audio.newSource('Paddle.wav', 'static'),
        ['bgm'] = love.audio.newSource('bgm.mp3','stream')
    }

    sounds['bgm']:play()

    -- Initialize window
    love.window.setTitle("SIN_GREED's PONGUH!")
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = true
    })
end

function love.resize(wid , hgt) 
    push:resize(wid,hgt)


end



-- Update function
function love.update(dt)
    if gameState == 'play' then
        -- Ball and paddle collision code
        if ball:collides(paddle1) then
            ball.dx = -ball.dx * 1.03
            ball.x = paddle1.x + 5

            sounds['paddle_hit']:play()
            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
        end

        if ball:collides(paddle2) then
            ball.dx = -ball.dx * 1.03
            ball.x = paddle2.x - 4
            sounds['paddle_hit']:play()
            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
        end

        if ball.y <= 0 then
            ball.dy = -ball.dy
            ball.y = 0
            sounds['wall_hit']:play()

        end
        if ball.y >= VIRTUAL_HEIGHT - 5 then
            ball.dy = -ball.dy
            ball.y = VIRTUAL_HEIGHT - 5
            sounds['wall_hit']:play()
        end

        ball:update(dt)
    end

    --Scoring
    if ball.x <= 0 then
        player2Score = player2Score + 1
        sounds['points_scored']:play()
        ball:reset()
        ball.dx = 100
        if player2Score >= 3 then 
            gameState = 'victory'
            winning = 2
            
        else
            serving = 1
            gameState = 'serve'
            
        end
            
    end

    if ball.x >= VIRTUAL_WIDTH - 5 then
        player1Score = player1Score + 1
        sounds['points_scored']:play()
        ball:reset()
        ball.dx = -100

        if player1Score >= 3 then

            gameState = 'victory'

            winning = 1
        
        else
    
            serving = 2
            gameState = 'serve'
        
        end
    end

    paddle1:update(dt)




    if love.keyboard.isDown('w') then
        paddle1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        paddle1.dy = PADDLE_SPEED
    else
        paddle1.dy = 0
    end

    if gameState == 'play' then
        local targetY = ball.y - paddle2.height / 2
        local tolerance = 5
        if math.abs(paddle2.y  - targetY) > tolerance then
            if paddle2.y < targetY then 
                
                paddle2.y = paddle2.y + PADDLE_SPEED * dt 
            elseif paddle2.y > targetY then 
                paddle2.y = paddle2.y - PADDLE_SPEED * dt 
            end
    
        end
    end
    


end

-- Key press function
function love.keypressed(key)
    if key == 'escape' then
        love.audio.stop()
        love.event.quit()

    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'victory' then 
            gameState = 'start'
            player1Score = 0
            player2Score = 0
        elseif gameState == 'serve' then 
            gameState = 'play'
        end

    end
end

-- Draw function
function love.draw()
    push:apply('start')

    -- Draw the background
    love.graphics.clear(0/255, 150/255, 150/255, 1)

    -- Draw paddles and ball
    paddle1:render()
    paddle2:render()
    ball:render()

    --Draw Messages
    love.graphics.setFont(smallFont)

    if gameState == 'start' then 
        love.graphics.printf("Welcome to Pong!" , 0 , 20 , VIRTUAL_WIDTH , 'center')
        love.graphics.printf("Press Enter to Play!" , 0,35 , VIRTUAL_WIDTH,'center')
        
    elseif gameState == 'serve' then 
        if serving == 1 then
            love.graphics.printf("Player 2's Serve!" , 0 , 20 , VIRTUAL_WIDTH , 'center')
            
        else
            love.graphics.printf("Player 1's Serve!" , 0 , 20 , VIRTUAL_WIDTH , 'center')
        end     
        love.graphics.printf("Press Enter to Serve!" , 0,35 , VIRTUAL_WIDTH,'center')
    elseif gameState == 'victory' then

        love.graphics.setFont(smallFont)
        love.graphics.printf('Player ' .. tostring(winning) .. " Wins!" , 0,20,VIRTUAL_WIDTH , 'center')
        love.graphics.printf("Press Enter to Play Again!" , 0,35 , VIRTUAL_WIDTH,'center')

        --victory
    end 



    -- Draw scores
    love.graphics.setFont(scoreFont)
    love.graphics.print(player1Score, VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(player2Score, VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)

    -- Display FPS
    displayFPS()

    push:apply('end')
end

-- Display FPS function
function displayFPS()
    love.graphics.setFont(smallFont)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end
