--Load, update, draw

--Init
function love.load()
    target = {}
    target.x = 300
    target.y = 300
    target.radius = 50

    score = 0
    --seconds
    timer = 10
    gamefont = love.graphics.newFont(40)
    --1 = main menu 2 = in game
    gamestate = 1

    sprites = {}
    sprites.sky = love.graphics.newImage('sprites/sky.png')
    sprites.target = love.graphics.newImage('sprites/target.png')
    sprites.crosshairs = love.graphics.newImage('sprites/crosshairs.png')
end

--tick / gameloop (60fps)
function love.update(dt)
   updateTimer(dt)
end

function updateTimer(dt)
    if gamestate == 2 then
        timer = timer - dt; 
        if timer <= 0 then
            timer = 0
            endGame()
        end
    end
end

function love.draw()
    drawBackground()
    if gamestate == 1 then
        drawStartGameText()        
    elseif gamestate == 2 then
        drawTarget()
    end
    drawCrosshair()
    drawTimer()
    drawScore()
    

    love.mouse.setVisible(gamestate == 1)    
end

function drawBackground()
    love.graphics.draw(sprites.sky, 0, 0 )
end

function drawTarget()
    love.graphics.draw(sprites.target, target.x - sprites.target:getWidth() / 2, target.y - sprites.target:getHeight() / 2 )
end

function drawCrosshair()
    --needs offset to center
    love.graphics.draw(sprites.crosshairs, love.mouse.getX() - sprites.crosshairs:getWidth() / 2, love.mouse.getY() - sprites.crosshairs:getHeight() / 2 )
end

function drawScore()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(gamefont)
    love.graphics.print("Score:"..score, 5, 5)
end

function drawTimer()
    love.graphics.print("Time:"..math.ceil(timer), 300, 5)
end 

function drawStartGameText()
    love.graphics.printf("Click to Start Game", 0, love.graphics.getHeight() / 2, love.graphics.getWidth(), "center")
end

function love.mousepressed(x, y, button, istouch, presses)
    if button == 1 then
        if gamestate == 1 then
            startGame()
        elseif gamestate == 2 then
            local mouseToTarget = distanceBetween(target.x, target.y, x, y);
            if mouseToTarget < target.radius then
                score = score + 1
                moveTarget()
            end
        end
    end
end

function startGame()
    timer = 10
    score = 0
    gamestate = 2
end

function endGame()
    gamestate = 1
end

function moveTarget()
    target.x = math.random(target.radius, love.graphics.getWidth() - target.radius)
    target.y = math.random(target.radius, love.graphics.getHeight() - target.radius)
end

function distanceBetween(x1, y1, x2, y2)
    return math.sqrt( (x2 - x1)^2 + (y2 - y1)^2 )
end