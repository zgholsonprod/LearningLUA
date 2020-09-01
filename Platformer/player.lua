playerStartX = 360
playerStartY = 100

player = world:newRectangleCollider(playerStartX, playerStartY, 40, 100, {collision_class = "Player"})
player:setFixedRotation(true)
player.speed = 240
player.animation = animations.idle
player.isMoving = false
--1 = right -1 == left
player.direction = 1
player.grounded = true

function playerUpdate(dt)
    player.isMoving = false
    if not player.body then
        return
    end
        
    local px, py = player:getPosition()
    if love.keyboard.isDown('right') then
        player:setX(px + player.speed * dt)
        player.isMoving = true
        player.direction = 1
    end
    if love.keyboard.isDown('left') then
        player:setX(px - player.speed * dt)
        player.isMoving = true
        player.direction = -1
    end

    local colliders = world:queryRectangleArea(player:getX() - 20, player:getY() + 50, 40, 2, {'Platform'})
    player.grounded = #colliders > 0
    if player.grounded then
        if player.isMoving then 
            player.animation = animations.run
        else
            player.animation = animations.idle
        end
    else
        player.animation = animations.jump
    end
    player.animation:update(dt)

    if player:enter('Danger') then 
        player:setPosition(playerStartX, playerStartY)
    end
end

function drawPlayer()
    if player.body then
        local px, py = player:getPosition()
        player.animation:draw(sprites.playerSheet, px, py, nil, 0.25 * player.direction, 0.25, 130, 300)
    end
end