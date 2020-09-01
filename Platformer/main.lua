function love.load()
    love.window.setMode(1000, 768)

    anim8 = require 'libraries/anim8/anim8'
    sti = require 'libraries/Simple-Tiled-Implementation/sti'
    camerafile = require 'libraries/hump/camera'

    cam = camerafile()

    sounds = {}
    sounds.jump = love.audio.newSource("audio/jump.wav", "static")
    sounds.music = love.audio.newSource("audio/music.mp3", "stream")
    sounds.music:setLooping(true)
    sounds.music:setVolume(.5)
    sounds.music:play()
    sprites = {}
    sprites.playerSheet  = love.graphics.newImage('sprites/playerSheet.png')
    sprites.enemySheet  = love.graphics.newImage('sprites/enemySheet.png')
    sprites.background  = love.graphics.newImage('sprites/background.png')

    local grid = anim8.newGrid(614, 564, sprites.playerSheet:getWidth(), sprites.playerSheet:getHeight())
    local enemyGrid = anim8.newGrid(100, 79, sprites.enemySheet:getWidth(), sprites.enemySheet:getHeight())

    animations = {}
    animations.idle = anim8.newAnimation(grid('1 - 15', 1), 0.05)
    animations.jump = anim8.newAnimation(grid('1 - 7', 2), 0.05)
    animations.run = anim8.newAnimation(grid('1 - 15', 3), 0.05)

    animations.enemy = anim8.newAnimation(enemyGrid('1 - 2', 1), 0.03)

    wf = require 'libraries/windfield/windfield'
    world = wf.newWorld(0, 800, false)
    world:setQueryDebugDrawing(true)
    world:addCollisionClass('Platform')
    world:addCollisionClass('Player')--, {ignores = {'Platform'}})
    world:addCollisionClass('Danger')

    require('player')
    require('enemy')
    require('libraries/show')

    dangerZone = world:newRectangleCollider(-500, 800, 5000, 50, {collision_class = "Danger"})
    dangerZone:setType('static')

    platforms = {}

    flagX = 0
    flagY = 0
    saveData = {}
    saveData.currentLevel = 1

    if love.filesystem.getInfo("data.lua") then
        local data = love.filesystem.load("data.lua")
        data()
    end

    loadMap(saveData.currentLevel)
end

function love.update(dt)
    world:update(dt)
    gameMap:update(dt)
    playerUpdate(dt)
    updateEnemies(dt)
    if player.body then
        local px, py = player:getPosition()
        cam:lookAt(px, love.graphics.getHeight()/2)
        local colliders = world:queryCircleArea(flagX, flagY, 10, {'Player'})
        if #colliders > 0 then
            loadMap(2)
        end
    end
end

function love.draw()
    love.graphics.draw(sprites.background, 0, 0)
    cam:attach()
        gameMap:drawLayer(gameMap.layers[1])
        --world:draw()
        drawPlayer()
        drawEnemies()
    cam:detach()
end

function love.keypressed(key)
    if player.body then
        if key == 'up' then
            performJump()
        end
        if key == 'r' then
            loadMap(2)
        end
    end
end

function performJump()
    local colliders = world:queryRectangleArea(player:getX() - 20, player:getY() + 50, 40, 2, {'Platform'})
    if(#colliders > 0) then
        player:applyLinearImpulse(0, -4000)
        player.animation = animations.jump
        sounds.jump:play()
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

function loadMap(mapIndex)
    saveData.currentLevel = mapIndex
    love.filesystem.write("data.lua", table.show(saveData, "saveData"))
    destroyPlatforms()
    destroyEnemies()
    
    gameMap = sti("maps/level"..mapIndex ..".lua")
    for i, obj in pairs(gameMap.layers["Platforms"].objects) do
        spawnPlatform(obj.x, obj.y, obj.width, obj.height)
    end
    for i, obj in pairs(gameMap.layers["Flag"].objects) do
        flagX = obj.x
        flagY = obj.y
    end
    for i, obj in pairs(gameMap.layers["Start"].objects) do
        playerStartX = obj.x
        playerStartY = obj.y
    end
    player:setPosition(playerStartX, playerStartY)
    spawnEnemies()
end

function spawnEnemies()
    for i, obj in pairs(gameMap.layers["Enemies"].objects) do
        spawnEnemy(obj.x, obj.y)
    end 
end

function destroyPlatforms()
    local i = #platforms
    while i > -1 do 
        if platforms[i] ~= nil then
            platforms[i]:destroy()
        end 
        table.remove(platforms, i)
        i = i - 1
    end
end

function destroyEnemies()
    local i = #enemies
    while i > -1 do 
        if enemies[i] ~= nil then
        enemies[i]:destroy()
        end 
        table.remove(enemies, i)
        i = i - 1
    end
 end