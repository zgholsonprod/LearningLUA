function love.load()
    love.window.setMode(1000, 768)

    anim8 = require 'libraries/anim8/anim8'
    sti = require 'libraries/Simple-Tiled-Implementation/sti'

    sprites = {}
    sprites.playerSheet  = love.graphics.newImage('sprites/playerSheet.png')

    local grid = anim8.newGrid(614, 564, sprites.playerSheet:getWidth(), sprites.playerSheet:getHeight())
    animations = {}
    animations.idle = anim8.newAnimation(grid('1 - 15', 1), 0.05)
    animations.jump = anim8.newAnimation(grid('1 - 7', 2), 0.05)
    animations.run = anim8.newAnimation(grid('1 - 15', 3), 0.05)

    wf = require 'libraries/windfield/windfield'
    world = wf.newWorld(0, 800, false)
    world:setQueryDebugDrawing(true)
    world:addCollisionClass('Platform')
    world:addCollisionClass('Player')--, {ignores = {'Platform'}})
    world:addCollisionClass('Danger')

    require('player')

    --dangerZone = world:newRectangleCollider(0, 550, 800, 50, {collision_class = "Danger"})
    --dangerZone:setType('static')

    platforms = {}

    loadMap()
end

function love.update(dt)
    world:update(dt)
    gameMap:update(dt)
    playerUpdate(dt)
end

function love.draw()
    gameMap:drawLayer(gameMap.layers[1])
    world:draw()
    drawPlayer()
end

function love.keypressed(key)
    if player.body then
        if key == 'up' then
            performJump()
        end
    end
end

function performJump()
    local colliders = world:queryRectangleArea(player:getX() - 20, player:getY() + 50, 40, 2, {'Platform'})
    if(#colliders > 0) then
        player:applyLinearImpulse(0, -4000)
        player.animation = animations.jump
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then
      
    end
end

function spawnPlatform(x, y, width, height)
    local platform = world:newRectangleCollider(x, y, width, height, {collision_class = "Platform"})
    platform:setType('static')
    table.insert(platforms, platform)
end

function loadMap()
    gameMap = sti('maps/level1.lua')
    for i, obj in pairs(gameMap.layers["Platforms"].objects) do
        spawnPlatform(obj.x, obj.y, obj.width, obj.height)
    end
end

