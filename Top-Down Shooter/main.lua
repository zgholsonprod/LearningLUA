function love.load()
sprites = {}
sprites.background = love.graphics.newImage('sprites/background.png')
sprites.bullet = love.graphics.newImage('sprites/bullet.png')
sprites.player = love.graphics.newImage('sprites/player.png')
sprites.zombie = love.graphics.newImage('sprites/zombie.png')

player = {}
player.x = love.graphics.getWidth() / 2
player.y = love.graphics.getHeight() / 2
player.speed = 180
player.rotation = 0
player.injured = false

zombies = {}
bullets = {}

gamestate = 1
maxTime = 2
maxTimeDecay = 0.95
timer = maxTime
myFont = love.graphics.newFont(30)

score = 0
end

function love.update(dt)
    if gamestate == 2 then
        updatePlayerMovement(dt)
        updateZombieMovement(dt)
        updateBulletMovement(dt)
        updateDeadObjects()
        updateSpawnTimer(dt)
    end
end

function updateSpawnTimer(dt)
    if gamestate == 2 then
        timer = timer - dt
        if timer <= 0 then
            spawnZombie()
            timer = maxTime
            maxTime = maxTimeDecay * maxTime
        end
    end
end

function updatePlayerMovement(dt)
    player.rotation = getRotationBetweenTwoPoints(love.mouse.getX(), love.mouse.getY(), player.x, player.y)

    if love.keyboard.isDown("w") then
        player.y = player.y - player.speed * dt
    end
    if love.keyboard.isDown("a") then
        player.x = player.x - player.speed * dt
    end
    if love.keyboard.isDown("s") then
        player.y = player.y + player.speed * dt
    end
    if love.keyboard.isDown("d") then
        player.x = player.x + player.speed * dt
    end
    --The player graphic is taller than it is wide.  don't let it go off screen even when it rotates
    player.x = clamp(sprites.player:getHeight() / 2, player.x, love.graphics.getWidth() - sprites.player:getHeight() / 2)
    player.y = clamp(sprites.player:getHeight() / 2, player.y, love.graphics.getHeight() - sprites.player:getHeight() / 2)
end

function updateZombieMovement(dt)
    for i, z in ipairs(zombies) do
        z.rotation = getRotationBetweenTwoPoints(player.x, player.y, z.x, z.y)
        z.x = z.x + math.cos(getRotationBetweenTwoPoints(player.x, player.y, z.x, z.y)) * z.speed * dt
        z.y = z.y + math.sin(getRotationBetweenTwoPoints(player.x, player.y, z.x, z.y)) * z.speed * dt

        if distanceBetween(player.x, player.y, z.x, z.y) < 20 then            
            if player.injured then
                endGame()
            else
                player.injured = true
                z.dead = true
            end
        end
    end
end

function updateBulletMovement(dt)
    for i=#bullets, 1, -1 do
        --validate it does not go off screen
        if bullets[i].x < 0 or bullets[i].y < 0 or bullets[i].x > love.graphics.getWidth() or bullets[i].y > love.graphics.getHeight() then
            bullets[i].dead = true
        else
            for j=#zombies, 1, -1 do
                if distanceBetween(bullets[i].x, bullets[i].y, zombies[j].x, zombies[j].y) < 20 then
                zombies[j].dead = true
                bullets[i].dead = true
                score = score + 1
                end
            end
        end
    end
    
    
    for i, b in ipairs(bullets) do
        b.x = b.x + math.cos(b.rotation) * b.speed * dt
        b.y = b.y + math.sin(b.rotation) * b.speed * dt
    end
end


function love.draw()
    drawBackground()
    drawPlayer()
    drawZombies()
    drawBullets()

    love.graphics.setFont(myFont)
    if gamestate == 1 then
        love.graphics.setFont(myFont)
        love.graphics.printf("Click anywhere to begin", 0, 50, love.graphics.getWidth(), "center");
    end
    love.graphics.printf("Score:"..score, 5, love.graphics.getHeight()-100, love.graphics.getWidth(), "center");
end


function drawBackground()
    love.graphics.draw(sprites.background, 0, 0)
end

function drawPlayer()
    if player.injured then
        love.graphics.setColor(1, 0, 0)
    else
        love.graphics.setColor(1, 1, 1)
    end
    love.graphics.draw(sprites.player, player.x, player.y, player.rotation, nil, nil, sprites.player:getWidth()/2, sprites.player:getHeight()/2)
    --reset the color
    love.graphics.setColor(1, 1, 1)
end

function drawZombies()
    for i, z in ipairs(zombies) do
        love.graphics.draw(z.graphic, z.x, z.y, z.rotation, nil, nil, z.graphic:getWidth()/2, z.graphic:getHeight()/2)
    end
end

function drawBullets()
    for i, b in ipairs(bullets) do
        love.graphics.draw(b.graphic, b.x, b.y, b.rotation, b.xScale, b.yScale, b.graphic:getWidth()/2, b.graphic:getHeight()/2)
    end
end

function spawnZombie()
    local zombie = {}
    zombie.x = math.random(sprites.zombie:getWidth()/2,  love.graphics.getWidth() - sprites.zombie:getWidth()/2)
    zombie.y = math.random(sprites.zombie:getHeight()/2,  love.graphics.getHeight() - sprites.zombie:getHeight()/2)
    zombie.speed = 140
    zombie.rotation = 0
    zombie.graphic = sprites.zombie
    zombie.dead = false

    local side = math.random(1, 4)
    --left
    if side == 1 then 
        zombie.x = -30
        zombie.y = math.random(0, love.graphics.getHeight())
    --right
    elseif side == 2 then 
        zombie.x = love.graphics.getWidth() + 30
        zombie.y = math.random(0, love.graphics.getHeight())
    end
    --top
    if side == 3 then 
        zombie.x = math.random(0, love.graphics.getWidth())
        zombie.y = love.graphics.getHeight() + 30
    end
    --bottom
    if side == 4 then 
        zombie.x = -30
        zombie.y = math.random(0, love.graphics.getWidth())
    end
    --add it to the table
    table.insert(zombies, zombie)
end

function spawnBullet(x, y, rot)
    local bullet = {}
    bullet.x = x
    bullet.y = y
    bullet.speed = 500
    bullet.xScale = .5
    bullet.yScale = .5
    bullet.rotation = rot
    bullet.graphic = sprites.bullet
    bullet.dead = false
    --add it to the table
    table.insert(bullets, bullet)
end

function updateDeadObjects()
    for i=#bullets, 1, -1 do
        if bullets[i].dead then
            table.remove(bullets, i)
        end
    end
    for i=#zombies, 1, -1 do
        if zombies[i].dead then
            table.remove(zombies, i)
        end
    end
end

function love.keypressed( key )
    if key == "space" then
        spawnZombie()
    end
end

function love.mousepressed( x, y, button )
    if button == 1 then
        if gamestate == 1 then
            startGame()
        else
            spawnBullet(player.x, player.y, player.rotation)
        end
    end
end

--returns the angle in radians 
function getRotationBetweenTwoPoints(x1, y1, x2, y2)
    rotation = math.atan2( y1 - y2, x1 - x2)
    return rotation
end

function clamp(min, val, max)
    return math.max(min, math.min(val, max));
end

function distanceBetween(x1, y1, x2, y2)
    return math.sqrt( (x2- x1)^2 + (y2 - y1)^2)
end

function startGame()
    gamestate = 2
    maxTime = 2
    score = 0
end

function endGame()
    gamestate = 1
    player.x = love.graphics.getWidth() / 2
    player.y = love.graphics.getHeight() / 2
    for i, z in ipairs(zombies) do
        zombies[i] = nil
    end
    player.injured = false
end